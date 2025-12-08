-- Clear search highlight
vim.keymap.set('n', '<Esc>', ':noh<CR>')

-- Clipboard (termux-api) - async to avoid blocking
local function copy_to_android(text)
  local job = vim.fn.jobstart({'termux-clipboard-set'}, {stdin = 'pipe'})
  vim.fn.chansend(job, text)
  vim.fn.chanclose(job, 'stdin')
end

vim.keymap.set('v', '<leader>y', function()
  vim.cmd('normal! y')
  copy_to_android(vim.fn.getreg('"'))
  print('Copied to Android clipboard')
end, { desc = "Copy to Android clipboard" })

vim.keymap.set('n', '<leader>Y', function()
  vim.cmd('normal! yy')
  copy_to_android(vim.fn.getreg('"'))
  print('Copied line to Android clipboard')
end, { desc = "Copy line to Android clipboard" })

vim.keymap.set({'n', 'i'}, '<leader>p', function()
  vim.fn.jobstart({'termux-clipboard-get'}, {
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
end, { desc = "Paste from Android clipboard" })

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
