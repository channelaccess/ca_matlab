classdef ChannelGroup
   properties
      current
      % TODO - Add more descriptive names for your channels here ...
   end

   methods
      % Constructor of class
      function obj = ChannelGroup(context, macro)
          import ch.psi.jcae.*

          obj.current = Channels.create(context, ChannelDescriptor('double', strcat(macro,':CURRENT')));
          % TODO - Create all channels you declared here ...
      end

      % Destructor
      function delete(obj)
        obj.current.close();
        % TODO - Close all your channels here ...
      end
   end
end
