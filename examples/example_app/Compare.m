%	Compare two arrays of strings
%		match = Compare(str1, str2, [match_case])
%
%		str1 & str2 can be character arrays, padded character arrays or
%		cellarrays of strings
%		match(n, m) = Compare(str1(n), str2(m))
%		match_case: determine if cases must match (default = false)
%
%	Author(s):
%		Dr Adam S Wyatt (adam.wyatt@stfc.ac.uk)

function match = Compare(str1, str2, match_case)

if nargin>2 && match_case
	fun = @strncmp;
else
	fun = @strncmpi;
end

if ismatrix(str1) && ~isvector(str1)
	str1 = mat2cell(str1, ones(size(str1, 1), 1), size(str1, 2));
end

if ismatrix(str2) && ~isvector(str2)
	str2 = mat2cell(str2, ones(size(str2, 1), 1), size(str2, 2));
end

if iscell(str1)
	match = cell2mat(cellfun(@(str) Compare(str, str2), str1, ...
		'UniformOutput', false));
elseif iscell(str2)
	match = cell2mat(cellfun(@(str) Compare(str1, str), str2, ...
		'UniformOutput', false));
else
	match = fun(str1, str2, min(length(str1), length(str2)));
end

end