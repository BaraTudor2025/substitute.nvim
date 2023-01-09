local utils = require("substitute.utils")
local config = require("substitute.config")

local substitute = {}

substitute.state = {
  register = nil,
}

function substitute.setup(options)
  substitute.config = config.setup(options)

  vim.api.nvim_set_hl(0, "SubstituteRange", { link = "Search", default = true })
  vim.api.nvim_set_hl(0, "SubstituteExchange", { link = "Search", default = true })
end

function substitute.operator(options)
  options = options or {}
  substitute.state.register = options.register or vim.v.register
  substitute.state.count = options.count or (vim.v.count > 0 and vim.v.count or 1)
  substitute.state.yank = options.yank or config.options.yank_substituted_to_register

  vim.o.operatorfunc = "v:lua.require'substitute'.operator_callback"
  vim.api.nvim_feedkeys("g@" .. (options.motion or ""), "i", false)
end

function substitute.operator_callback(vmode)
  local marks = utils.get_marks(0, vmode)

  local substitued_text = utils.text(0, marks.start, marks.finish, vmode)

  local regcontents = vim.fn.getreg(substitute.state.register)
  local regtype = vim.fn.getregtype(substitute.state.register)
  local replacement = vim.split(regcontents:rep(substitute.state.count):gsub("\n$", ""), "\n")

  utils.substitute_text(0, marks.start, marks.finish, vmode, replacement, regtype)

  if config.options.yank_substituted_text or substitute.state.yank then
    local reg = utils.get_default_register()
    -- use register provided by call with arg {yank="<reg>"}
    if type(substitute.state.yank) == "string" then
      reg = substitute.state.yank
    end
    vim.fn.setreg(reg, table.concat(substitued_text, "\n"), utils.get_register_type(vmode))
  end

  if config.options.on_substitute ~= nil then
    config.options.on_substitute({
      marks = marks,
      register = substitute.state.register,
      count = substitute.state.count,
      vmode = vmode,
      -- text = table.concat(substituted_text, "\n"),
    })
  end
end

function substitute.line(options)
  options = options or {}
  local count = options.count or (vim.v.count > 0 and vim.v.count or "")
  substitute.operator({
    motion = count .. "_",
    count = 1,
    register = options.register or vim.v.register,
  })
end

function substitute.eol(options)
  options = options or {}
  substitute.operator({
    motion = "$",
    register = options.register or vim.v.register,
    count = options.count or (vim.v.count > 0 and vim.v.count or 1),
  })
end

function substitute.visual(options)
  options = options or {}
  substitute.state.register = options.register or vim.v.register
  substitute.state.count = options.count or (vim.v.count > 0 and vim.v.count or 1)
  vim.o.operatorfunc = "v:lua.require'substitute'.operator_callback"
  vim.api.nvim_feedkeys("g@`<", "i", false)
end

return substitute
