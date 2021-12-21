local utils = require("substitute.utils")

describe("Test get region", function()
  it("should find region", function()
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_command("buffer " .. buf)
    vim.api.nvim_buf_set_lines(0, 0, -1, true, {
      "Lorem",
      "Ipsum",
    })

    vim.api.nvim_buf_set_mark(buf, "[", 1, 1, {})
    vim.api.nvim_buf_set_mark(buf, "]", 2, 2, {})

    local region = utils.get_region("char")

    assert(region.start_col == 1)
    assert(region.start_row == 1)
    assert(region.end_col == 2)
    assert(region.end_row == 2)
  end)
end)