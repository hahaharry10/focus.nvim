local M = {}

-- TODO: Add feature allowing mulitple highlights on a page.

-- Param: Table, 'coords':
--      coords.end_row: the final row/line of the selected area,
--      coords.end_col: the column the selected area ends on the final row.
--      coords.start_row: the first row/line of the selected area.
--      coords.start_col: the column the selected area starts on the first row.
function M:highlight(coords)
    coords = coords or {}

    print(vim.inspect(coords))

    if coords == {} then
        return
    end

    if coords.end_row < coords.start_row or (coords.end_row == coords.start_row and coords.end_col < coords.start_col) then
        -- swap line numbers
        local buf = coords.end_row
        coords.end_row = coords.start_row
        coords.start_row = buf

        -- swap column numbers
        buf = coords.end_col
        coords.end_col = coords.start_col
        coords.start_col = buf
    end

    -- Ensure 1-based indexing:
    coords.end_row = (coords.end_row > 0) and coords.end_row or 1
    coords.end_col = (coords.end_col > 0) and coords.end_col or 1
    coords.start_row = (coords.start_row > 0) and coords.start_row or 1
    coords.start_col = (coords.start_col > 0) and coords.start_col or 1

    local function getColour()
        local str = vim.api.nvim_exec2("hi Comment", { output = true }).output
        local start_index = string.find(str, "guifg=")
        local end_index = string.find(str, " ", start_index)
        return string.sub(str, start_index+string.len("guifg="), end_index)
    end



    local colour = getColour()

    self.namespace_name = "perma_hl"
    self.namespace_id = vim.api.nvim_create_namespace(self.namespace_name)

    local hl_group = "perma_hl_group"
    vim.api.nvim_set_hl(0, hl_group, { fg = colour, default = false })


    vim.api.nvim_buf_clear_namespace(0, self.namespace_id, 0, -1)
    for i = 1, vim.fn.line("$") do
        if i < coords.start_row or i > coords.end_row then
            vim.api.nvim_buf_add_highlight(
                vim.api.nvim_get_current_buf(),
                self.namespace_id,
                hl_group,
                i-1,
                0,
                -1
            )
        elseif i == coords.start_row and coords.start_col > 1 then
            vim.api.nvim_buf_add_highlight(
                vim.api.nvim_get_current_buf(),
                self.namespace_id,
                hl_group,
                i-1,
                0,
                coords.start_col-1
            )

        elseif i == coords.end_row and coords.end_col < vim.fn.col({coords.end_row, "$"}) then
            vim.api.nvim_buf_add_highlight(
                vim.api.nvim_get_current_buf(),
                self.namespace_id,
                hl_group,
                i-1,
                coords.end_col,
                -1
            )
        end
    end
end

function M:unfocus()
    vim.api.nvim_buf_clear_namespace(0, self.namespace_id, 0, -1)
end

function M:focus_visual_selection()
    local mode = vim.api.nvim_exec2("echo mode()", { output = true }).output
    if mode ~= "v" and mode ~= "V" then
        print("ERROR: Function can only be called in Visual or Visual-Line mode")
        return
    end

    local start_pos = vim.fn.getcharpos(".")
    local end_pos = vim.fn.getcharpos("v")

    local coords = {}
    coords.end_row = end_pos[2]
    coords.end_col = end_pos[3]
    coords.start_row = start_pos[2]
    coords.start_col = start_pos[3]

    if mode == "V" then -- is mode Visual Line?
        if coords.end_row > coords.start_row then
            coords.end_col = vim.fn.col({coords.end_row, "$"})
            coords.start_col = 0
        else
            coords.start_col = vim.fn.col({coords.start_row, "$"})
            coords.end_col = 0
        end
    end


    self:highlight(coords)
end

return M

