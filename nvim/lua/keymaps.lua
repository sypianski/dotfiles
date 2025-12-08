-- Clear search highlight
vim.keymap.set('n', '<Esc>', ':noh<CR>')

-- Clipboard - OSC 52 for remote, native tools for local
local function is_ssh_session()
  return vim.env.SSH_CLIENT ~= nil or vim.env.SSH_TTY ~= nil
end

local function osc52_copy(text)
  local b64 = vim.base64.encode(text)
  local osc = string.format('\x1b]52;c;%s\x07', b64)
  -- Write to tty to bypass tmux buffering
  local tty = io.open('/dev/tty', 'w')
  if tty then
    tty:write(osc)
    tty:close()
  end
end

local function get_local_clipboard()
  if vim.fn.executable('termux-clipboard-set') == 1 then
    return { copy = {'termux-clipboard-set'}, paste = {'termux-clipboard-get'}, name = 'Android' }
  elseif vim.fn.executable('wl-copy') == 1 then
    return { copy = {'wl-copy'}, paste = {'wl-paste'}, name = 'Wayland' }
  elseif vim.fn.executable('xclip') == 1 then
    return { copy = {'xclip', '-selection', 'clipboard'}, paste = {'xclip', '-selection', 'clipboard', '-o'}, name = 'X11' }
  elseif vim.fn.executable('xsel') == 1 then
    return { copy = {'xsel', '--clipboard', '--input'}, paste = {'xsel', '--clipboard', '--output'}, name = 'X11' }
  end
  return nil
end

local function copy_to_clipboard(text)
  if is_ssh_session() then
    osc52_copy(text)
    return 'Remote (OSC52)'
  end
  local clipboard = get_local_clipboard()
  if clipboard then
    local job = vim.fn.jobstart(clipboard.copy, {stdin = 'pipe'})
    vim.fn.chansend(job, text)
    vim.fn.chanclose(job, 'stdin')
    return clipboard.name
  end
  return nil
end

vim.keymap.set('v', '<leader>y', function()
  vim.cmd('normal! y')
  local dest = copy_to_clipboard(vim.fn.getreg('"'))
  print('Copied to ' .. (dest or 'nowhere'))
end, { desc = "Copy to system clipboard" })

vim.keymap.set('n', '<leader>Y', function()
  vim.cmd('normal! yy')
  local dest = copy_to_clipboard(vim.fn.getreg('"'))
  print('Copied line to ' .. (dest or 'nowhere'))
end, { desc = "Copy line to system clipboard" })

vim.keymap.set({'n', 'i'}, '<leader>p', function()
  -- OSC 52 paste not widely supported; use local clipboard or Neovim's + register
  if is_ssh_session() then
    -- On remote, try the + register (requires clipboard provider)
    local text = vim.fn.getreg('+')
    if text ~= '' then
      vim.api.nvim_paste(text, true, -1)
    else
      print('Paste: use Ctrl+Shift+V or terminal paste')
    end
    return
  end
  local clipboard = get_local_clipboard()
  if not clipboard then
    print('No clipboard tool found')
    return
  end
  vim.fn.jobstart(clipboard.paste, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      if data then
        local text = table.concat(data, '\n')
        vim.schedule(function()
          vim.api.nvim_paste(text, true, -1)
        end)
      end
    end,
  })
end, { desc = "Paste from system clipboard" })

-- Frecency (recent/frequent files)
vim.keymap.set("n", "<leader>fr", "<cmd>Telescope frecency<cr>", { desc = "Frecency files" })
vim.keymap.set("n", "<leader>fR", "<cmd>Telescope frecency workspace=CWD<cr>", { desc = "Frecency (CWD only)" })

-- Persistence (sessions)
vim.keymap.set("n", "<leader>ps", function() require("persistence").load() end, { desc = "Restore session (cwd)" })
vim.keymap.set("n", "<leader>pl", function() require("persistence").load({ last = true }) end, { desc = "Restore last session" })
vim.keymap.set("n", "<leader>px", function() require("persistence").stop() end, { desc = "Don't save session" })

-- Substitute (paste without overwriting register)
vim.keymap.set("n", "s", function() require("substitute").operator() end)
vim.keymap.set("n", "ss", function() require("substitute").line() end)
vim.keymap.set("x", "s", function() require("substitute").visual() end)

-- Exchange (swap two text regions)
vim.keymap.set("n", "sx", function() require("substitute.exchange").operator() end)
vim.keymap.set("n", "sxx", function() require("substitute.exchange").line() end)
vim.keymap.set("x", "sx", function() require("substitute.exchange").visual() end)
vim.keymap.set("n", "sxc", function() require("substitute.exchange").cancel() end)

-- Range (find and replace in range)
vim.keymap.set("n", "<leader>s", function() require("substitute.range").operator() end)
vim.keymap.set("x", "<leader>s", function() require("substitute.range").visual() end)
vim.keymap.set("n", "<leader>ss", function() require("substitute.range").word() end)

-- Colorschemes (e-ink optimized)
local eink_schemes = { "eink-clear", "eink-soft", "eink-vivid", "eink-sepia" }
local current_scheme = 1

local function load_eink_scheme(name)
  package.loaded["colors." .. name] = nil
  require("colors." .. name)
end

local function cycle_colorscheme()
  current_scheme = current_scheme % #eink_schemes + 1
  load_eink_scheme(eink_schemes[current_scheme])
  print("Colorscheme: " .. eink_schemes[current_scheme])
end

vim.keymap.set("n", "<leader>cc", cycle_colorscheme, { desc = "Cycle e-ink colorscheme" })
vim.keymap.set("n", "<leader>c1", function() load_eink_scheme("eink-clear") end, { desc = "eink-clear" })
vim.keymap.set("n", "<leader>c2", function() load_eink_scheme("eink-soft") end, { desc = "eink-soft" })
vim.keymap.set("n", "<leader>c3", function() load_eink_scheme("eink-vivid") end, { desc = "eink-vivid" })
vim.keymap.set("n", "<leader>c4", function() load_eink_scheme("eink-sepia") end, { desc = "eink-sepia" })
