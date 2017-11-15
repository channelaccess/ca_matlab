javaaddpath('ca_matlab-1.0.0.jar')
import ch.psi.jcae.*
properties = java.util.Properties();

properties.setProperty('EPICS_CA_ADDR_LIST', getenv('EPICS_CA_ADDR_LIST'));
context = Context(properties);
channel = Channels.create(context, ChannelDescriptor('double', 'S10CB01-RBOC-DCP10:FOR-AMPLT-MAX'));

channel.get()

context.close();
