% This code snippet prints out the current ring current of SLS

% Import the library
% TODO: Remember to copy the ca_matlab library into the directory containing this file
if not(exist('java_classpath_set'))
    javaaddpath('ca_matlab-1.0.0.jar')
    java_classpath_set = 1;
end

import ch.psi.jcae.*

% Use of SLS configuration
properties = java.util.Properties();
properties.setProperty('EPICS_CA_ADDR_LIST', 'sls-cagw');
properties.setProperty('EPICS_CA_SERVER_PORT', '5062');

context = Context(properties);


channel = Channels.create(context, ChannelDescriptor('double', 'ARIDI-PCT:CURRENT', true));

example_g = openfig('gui.fig');      % opens GUI1
gui_properties = guihandles(example_g); 

collect_data_flag = 1;

while ishandle(example_g)
    disp '.'
    set(gui_properties.text_value, 'String', channel.get());
    pause(1)
end

if ishandle(example_g)
    close(example_g)
end

channel.close();
context.close();