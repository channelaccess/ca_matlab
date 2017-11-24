function output = ExtractStrings(strs, expr, return_strings, match_case)
% Extract a subset of strings based on a regular expression
%
%	output = ExtractStrings(strs, expr, return_strings, match_case)
%
%	output	= either:
%		logical array of matched strings [return_strings==false]
%		cellarray of matched strings [return_strings==true]
%	str		= cell array of input strings
%	expr	= regular expression string
%	return_strings	=	(optional) flag to determine output
%					>0 --> Return strings that match regexp
%					<0 --> Return strings that don't match regexp
%	match_case = (optional) flag to match case (default = false).
%					if true, use regexp, else use regexpi
%
%	Example:
%		str = {'Data1.mat'; 'Data2.mat'; 'Text.dat'};
%		str1 = ExtractStrings(str, '.mat', true);
%		%	str1 = {'Data1.mat'; 'Data2.mat'};
%
%	Author: Dr Adam S Wyatt

if ~exist('match_case', 'var') || isempty(match_case)
	RegExpFun = @regexpi;
else
	RegExpFun = @regexp;
end


output = cellfun(@(c) ~isempty(c), RegExpFun(strs, expr, 'once'));
if exist('return_strings', 'var') 
	if return_strings>0
		output = strs(output);
	elseif return_strings<0
		output = strs(~output);
	end
end
