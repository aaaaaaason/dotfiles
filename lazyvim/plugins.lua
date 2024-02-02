-- since this is just an example spec, don't actually load anything here and return an empty spec
-- stylua: ignore
-- if true then return {} end

-- every spec file under the "plugins" directory will be loaded automatically by lazy.nvim
--
-- In your plugin files, you can:
-- * add extra plugins
-- * disable/enabled LazyVim plugins
-- * override the configuration of LazyVim plugins
return {
  -- add gruvbox
  {
    "craftzdog/solarized-osaka.nvim",
    lazy = false,
    priority = 1000,
    opts = {},
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "solarized-osaka",
    },
  },
  {
    "folke/which-key.nvim",
    opts = {
      defaults = {
        ["<leader>r"] = { name = "+run command" },
      },
    },
  },
  {
    'akinsho/toggleterm.nvim',
    version = "*",
    keys = {
      {"<M-1>", "<cmd>1ToggleTerm<CR>", mode = {"n", "t"}, desc = "Toggle terminal 1" },
      {"<M-2>", "<cmd>2ToggleTerm<CR>", mode = {"n", "t"}, desc = "Toggle terminal 2" },
      {"<M-3>", "<cmd>3ToggleTerm<CR>", mode = {"n", "t"}, desc = "Toggle terminal 3" },
      {"<M-4>", "<cmd>4ToggleTerm<CR>", mode = {"n", "t"}, desc = "Toggle terminal 4" },

      {"<leader>r1", "<cmd>ToggleTermSendCurrentLine 1<CR>", mode = "n", desc = "current line to terminal 1" },
      {"<leader>r2", "<cmd>ToggleTermSendCurrentLine 2<CR>", mode = "n", desc = "current line to terminal 2" },
      {"<leader>r3", "<cmd>ToggleTermSendCurrentLine 3<CR>", mode = "n", desc = "current line to terminal 3" },
      {"<leader>r4", "<cmd>ToggleTermSendCurrentLine 4<CR>", mode = "n", desc = "current line to terminal 4" },

      {"<leader>r1", "<cmd>ToggleTermSendVisualLines 1<CR>V", mode = "v", desc = "selected lines to terminal 1" },
      {"<leader>r2", "<cmd>ToggleTermSendVisualLines 2<CR>V", mode = "v", desc = "selected lines to terminal 2" },
      {"<leader>r3", "<cmd>ToggleTermSendVisualLines 3<CR>V", mode = "v", desc = "selected lines to terminal 3" },
      {"<leader>r4", "<cmd>ToggleTermSendVisualLines 4<CR>V", mode = "v", desc = "selected lines to terminal 4" },
    },
    opts = {
      size = 40,
      direction = "horizontal",
      winbar = {
        enabled = true,
      }
    },
  },
  {
    "christoomey/vim-tmux-navigator",
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
    },
    keys = {
      { "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>" },
      { "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>" },
      { "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>" },
      { "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>" },
      { "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
    },
    config = function ()
      vim.g.tmux_navigator_disable_when_zoomed = 1
    end
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      window = {
        mappings = {
          ["s"] = "none",
          ["S"] = "none",
          ["f"] = "none",
          ["F"] = "none",
        }
      }
    }
  },
}
