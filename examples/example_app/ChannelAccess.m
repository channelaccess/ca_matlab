classdef ChannelAccess < uiobjects.Object & handle
	

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%	P R O P E R T I E S
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	properties
		Context;
		Channels = {};
	end
	
	
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%	P R O P E R T I E S (Dependent, SetAccess=private)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	properties (Dependent, SetAccess=private)
		ChannelNames;
		EmptyChannels;
	end
	
	
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%	P R O P E R T I E S (Hidden, Constant)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	properties (Hidden, Constant)
		NChannels = 100;
	end
	
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%	M E T H O D S
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	methods
		
		%	====================================================================

		function obj = ChannelAccess(varargin)
			
			%	Add java library (if required)
			obj.AddLibrary;
			
			%	Create channel cell array
% 			obj.Channels = cell(obj.NChannels, 1);			
			obj.Channels = {[]};			

			%	Check if context already supplied
			obj.Context = obj.FindArg(varargin, 'Context', []);
			if ~isempty(obj.Context)
				return;
			end
			
			%	Create java property object
			Prop = java.util.Properties();
			prop = obj.FindArg(varargin, 'Properties', {});
			if ~isempty(prop)
				for n=1:2:length(prop)
					Prop.setProperty(prop(n), prop(n+1));
				end
			end
			
			%	Create new context
			obj.Context = ch.psi.jcae.Context(Prop);
		end
		
		%	====================================================================

		function val = get.ChannelNames(obj)
			val = cell(size(obj.Channels));
			indx = ~obj.EmptyChannels;
			val(indx) = cellfun(@(CH) char(CH.getName), obj.Channels(indx), ...
				'UniformOutput', false);
		end
		
		%	====================================================================
		
		function val = get.EmptyChannels(obj)
			val = cellfun(@(CH) isempty(CH), obj.Channels);
		end
		
		%	====================================================================

		function indx = FindChannelIndex(obj, str, fnd)
			%	Search through list of channel names
			indx = cellfun(@(c) ~isempty(c), regexp(obj.ChannelNames, str, ...
				'once'));
			
			%	If required, convert logical array to index value
			if nargin>2 && fnd
				indx = find(indx);
			end
		end
		
		%	====================================================================

		function indx = AddChannel(obj, type, macro, monitor)
			monitor = nargin>3 && monitor;
			
			%	Create channel
			CH = obj.Context.createChannel(ch.psi.jcae.ChannelDescriptor( ...
				type, macro, monitor));
			
			%	Find empty space
			indx = find(obj.EmptyChannels, 1, 'first');
			if isempty(indx)
				%	No empty space - increase channel vector
				indx = length(obj.Channels)+1;
				obj.Channels = [obj.Channels; cell(obj.NChannels, 1)];
			end
			
			%	Insert new channel
			obj.Channels{indx} = CH;
		end
		
		%	====================================================================

		function indx = DeleteChannel(obj, indx)
			%	Macro supplied - get channel index
			if ischar(indx)
				indx = obj.ChannelIndex(indx, true);
			end
			
			%	Close channel
			obj.Channels{indx}.close;
			
			%	Empty channel handle
			obj.Channels{indx} = [];
		end
		
		%	====================================================================

		function PurgeChannels(obj)
			indx = find(~obj.EmptyChannels, 1, 'last');
			if isempty(indx)
				indx = 0;
			end
				obj.Channels(indx+1:end) = [];
		end
		
		%	====================================================================

		function delete(obj)
			for n=1:length(obj.Channels)
				try
					obj.Channels{n}.close;
					obj.Channels{n} = [];
				end
			end
% 			cellfun(@(CH) CH.close, obj.Channels(~obj.EmptyChannels));
% 			obj.CH = {};
			obj.Context.close;
		end
		
		%	====================================================================

	end
	
	
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%	M E T H O D S (Static)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	methods (Static)
		
		%	====================================================================

		function AddLibrary
			%	Name of assembly
			str = 'ca_matlab.jar';
			pth = fileparts(which('EPICS.ChannelAccess'));
			
			if ~any(cell2mat(regexp(javaclasspath('-dynamic'), ...
					str, 'once')))
				javaaddpath(fullfile(pth, str));
			end
		end
		
		%	====================================================================

	end
	
end