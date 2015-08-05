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
channel = context.createChannel(ChannelDescriptor('double', 'ARIDI-PCT:CURRENT'));

channel.get()

channel.close();
context.close();
