local api = vim.api
local q = require("vim.treesitter.query")
local namespace = vim.api.nvim_create_namespace("xunit")
local bufnr = api.nvim_get_current_buf()

local function debug(value)
	print(vim.inspect(value))
end

-- get the syntax_tree
local language_tree = vim.treesitter.get_parser(bufnr, "c_sharp")
local syntax_tree = language_tree:parse()
local root = syntax_tree[1]:root()

-- ts queries
local q_namespace = vim.treesitter.parse_query(
	"c_sharp",
	[[
  (namespace_declaration
    name: (qualified_name) @namespace) 
]]
)

local q_classname = vim.treesitter.parse_query(
	"c_sharp",
	[[
  (class_declaration
    name: (identifier) @class)
]]
)

local q_test_case = vim.treesitter.parse_query(
	"c_sharp",
	[[
    (method_declaration
      (attribute_list
        (attribute
          name: (identifier) @fact (#eq? @fact "Fact") (#offset! @fact)))
    name: (identifier) @test_case)
]]
)

-- get namespace
local ns
for _, captures in q_namespace:iter_matches(root, bufnr) do
	ns = q.get_node_text(captures[1], bufnr)
end

-- get class
local cls
for _, captures in q_classname:iter_matches(root, bufnr) do
	cls = q.get_node_text(captures[1], bufnr)
end

-- get tests
local tests = {}
local i = 1
for _, captures, metadata in meth_query:iter_matches(root, bufnr) do
	local test = q.get_node_text(captures[2], bufnr)
	-- collect all tests in file
	table.insert(tests, i, { test, metadata[1].range[1], metadata })
	i = i + 1
end

for key, test in pairs(tests) do
	debug(key)
	debug(test)
	debug("name: " .. test[1])
	debug("line: " .. test[2])
	debug(type(test[2]))
	debug(test[3])
end

local test_path = ns .. "." .. cls .. "." .. tests[1][1]
debug(test_path)