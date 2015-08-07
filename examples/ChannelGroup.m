classdef ChannelGroup

   properties
      current
   end

   methods

      % Constructor of class
      function obj = ChannelGroup(context, macro)
          import ch.psi.jcae.*

          obj.current = Channels.create(context, ChannelDescriptor('double', strcat(macro,':CURRENT')));
          % ...

      end

      % Destructor
      function delete(obj)
        obj.current.close();
      end
   end
end
