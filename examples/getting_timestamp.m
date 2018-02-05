javaaddpath('ca_matlab-1.0.0.jar')


import ch.psi.jcae.*
import ch.psi.jcae.impl.type.*

properties = java.util.Properties();
properties.setProperty('EPICS_CA_ADDR_LIST', getenv('EPICS_CA_ADDR_LIST'));
properties.setProperty('EPICS_CA_SERVER_PORT', getenv('EPICS_CA_SERVER_PORT'));

context = Context(properties);

channelType = DoubleTimestamp()
channel = Channels.create(context, ChannelDescriptor(channelType.getClass(), 'ARIDI-PCT:CURRENT'));

value = channel.get();
value.getValue()
value.getTimestamp()