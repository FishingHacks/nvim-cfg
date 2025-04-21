local conditions = require("heirline.conditions")
local heirline = require("heirline")
local utils = require("heirline.utils")

local mode = {
  init = function(self) self.mode = vim.fn.mode(1) end,
  static = {
    mode_names = {
      n = "Normal",
      no = "Normal",
      nov = "Normal",
      noV = "Normal",
      ["no\22"] = "Normal",
      niI = "Normal",
      niR = "Normal",
      niV = "Normal",
      nt = "Normal",
      v = "Visual",
      vs = "Visual",
      V = "Visual",
      Vs = "Visual",
      ["\22"] = "Visual",
      ["\22s"] = "Visual",
      s = "Visual",
      S = "Visual",
      ["\19"] = "Visual",
      i = "Insert",
      ic = "Insert",
      ix = "Insert",
      R = "Replace",
      Rc = "Replace",
      Rx = "Replace",
      Rv = "Replace",
      Rvc = "Replace",
      Rvx = "Replace",
      c = "Command",
      cv = "Command",
      r = "Accepts",
      rm = "More",
      ["r?"] = "Confirm",
      ["!"] = "Terminal",
      t = "Terminal",
    },
    mode_colors = {
      n = "red",
      i = "green",
      v = "cyan",
      V = "cyan",
      ["\22"] = "cyan",
      c = "orange",
      s = "purple",
      S = "purple",
      ["\19"] = "purple",
      R = "orange",
      r = "orange",
      ["!"] = "red",
      t = "red",
    },
    mode_fg = {
      n = "white",
      i = "white",
      v = "black",
      V = "black",
      ["\22"] = "black",
      c = "black",
      s = "white",
      S = "white",
      ["\19"] = "white",
      R = "black",
      r = "black",
      ["!"] = "white",
      t = "white",
    },
  },
  {
    provider = function(self) return "  " .. self.mode_names[self.mode] .. "  " end,
    hl = function(self)
      local mode = self.mode:sub(1, 1)
      return { bg = self.mode_colors[mode], fg = self.mode_fg[mode], bold = true }
    end,
  },
  update = {
    "ModeChanged",
    pattern = "*:*",
    callback = vim.schedule_wrap(function() vim.cmd("redrawstatus") end),
  },
}

local file_name_block = {
  init = function(self)
    self.filename = vim.api.nvim_buf_get_name(0)
    if vim.bo.buftype == "terminal" then self.filename = vim.api.nvim_buf_get_name(0):gsub(".*:", "") end
  end,
}

local file_icon = {
  init = function(self)
    local filename = self.filename
    local extension = vim.fn.fnamemodify(filename, ":e")
    self.icon, self.icon_color = require("nvim-web-devicons").get_icon_color(filename, extension, { default = true })
    if vim.bo.buftype == "terminal" then
      self.icon = " "
      self.icon_color = "white"
    end
  end,
  provider = function(self) return self.icon and (self.icon .. " ") end,
  hl = function(self) return { fg = self.icon_color } end,
}

local file_name = {
  provider = function(self)
    local filename = vim.fn.fnamemodify(self.filename, ":.")
    if filename == "" then return "[No Name]" end
    if not conditions.width_percent_below(#filename, 0.25) then filename = vim.fn.pathshorten(filename) end
    return filename
  end,
  hl = { fg = utils.get_highlight("Directory").fg },
}

local fileflags = {
  {
    condition = function() return vim.bo.modified end,
    provider = " [+]",
    hl = { fg = "green" },
  },
  {
    condition = function() return (not vim.bo.modifiable or vim.bo.readonly) and vim.bo.buftype ~= "terminal" end,
    provider = " ",
    hl = { fg = "orange" },
  },
}

local filename_mod = {
  hl = function()
    if vim.bo.modified then return { fg = "cyan", bold = true, force = true } end
  end,
}

file_name_block =
  utils.insert(file_name_block, file_icon, utils.insert(filename_mod, file_name), fileflags, { provider = "%<" })

local ruler = {
  -- %l = current line number
  -- %L = number of lines in the buffer
  -- %c = column number
  -- %P = percentage through file of displayed window
  provider = "%7(%l/%3L%):%2c ",
}

local diagnostics = {
  condition = conditions.has_diagnostics,
  static = {
    error_icon = " \u{f52f} ",
    warn_icon = " \u{ea6c} ",
    info_icon = " \u{f0336} ",
    hint_icon = " \u{f0336} ",
  },
  init = function(self)
    self.errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
    self.warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
    self.hints = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
    self.info = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
  end,
  update = { "DiagnosticChanged", "BufEnter" },
  on_click = {
    callback = function() vim.diagnostic.setloclist({}) end,
    name = "open_diagnostics",
    minwid = 0,
  },
  {
    provider = function(self)
      -- 0 is just another output, we can decide to print it or not!
      return self.errors > 0 and (self.error_icon .. self.errors .. " ")
    end,
    hl = { fg = "red" },
  },
  {
    provider = function(self) return self.warnings > 0 and (self.warn_icon .. self.warnings .. " ") end,
    hl = { fg = "yellow" },
  },
  {
    provider = function(self) return self.info > 0 and (self.info_icon .. self.info .. " ") end,
    hl = { fg = "gray" },
  },
  {
    provider = function(self) return self.hints > 0 and (self.hint_icon .. self.hints) end,
    hl = { fg = "gray" },
  },
}

local align = { provider = "%=" }
local space = { provider = " " }

local tabline_bufnr = {
  provider = function(self) return tostring(self.buffer) .. ". " end,
  hl = "Comment",
}

local tabline_filename = {
  provider = function(self)
    local filename = vim.api.nvim_buf_get_name(self.buffer)
    filename = filename == "" and "[No Name]" or vim.fn.fnamemodify(filename, ":.")
    return filename
  end,
  hl = function(self) return { bold = self.is_active or self.is_visible } end,
}

local tabline_fileflags = {
  {
    condition = function(self) return vim.api.nvim_get_option_value("modified", { buf = self.buffer }) end,
    provider = " [+]",
    hl = { fg = "green" },
  },
  {
    condition = function(self)
      return not vim.api.nvim_get_option_value("modifiable", { buf = self.buffer })
        or vim.api.nvim_get_option_value("readonly", { buf = self.buffer })
    end,
    provider = function(self)
      if vim.api.nvim_get_option_value("buftype", { buf = self.buffer }) == "terminal" then
        return ""
      else
        return "  "
      end
    end,
    hl = { fg = "orange" },
  },
}

local tabline_fileicon = {
  init = function(self)
    local filename = vim.api.nvim_buf_get_name(self.buffer)
    local extension = vim.fn.fnamemodify(filename, ":e")
    self.icon, self.icon_color = require("nvim-web-devicons").get_icon_color(filename, extension, { default = true })
    if vim.bo[self.buffer].buftype == "terminal" then
      self.icon = ""
      self.icon_color = "white"
    end
  end,
  provider = function(self) return self.icon and (self.icon .. " ") end,
  hl = function(self) return { fg = self.icon_color } end,
}

local tabline_filename_block = {
  init = function(self) self.buffer = vim.api.nvim_win_get_buf(vim.api.nvim_tabpage_get_win(self.tabpage)) end,
  hl = "TabLine",
  tabline_bufnr,
  tabline_fileicon,
  tabline_filename,
  tabline_fileflags,
}

local tabline_buffer_block = utils.surround(
  { "", "" },
  function() return utils.get_highlight("TabLine").bg end,
  { tabline_filename_block }
)

local tabline = utils.make_tablist({ tabline_buffer_block })
local statusline = {
  mode,
  space,
  file_name_block,
  align,
  space,
  diagnostics,
  space,
  ruler,
}

heirline.setup({
  statusline = statusline,
  tabline = { tabline },
})
