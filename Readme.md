# Overview
Jcae can be used to easily interface Epics via Channel Access within Matlab. This document describes how to do so within Matlab. On the exact jcae API details please refer to the general [Readme.md](Readme.md).

The latest stable package can be downloaded [here](http://slsyoke4.psi.ch:8081/artifactory/releases/jcae_all-2.7.1.jar).

The *prerequisites* for this package is *Matlab2015a* or later. There are absolutely no other dependencies beside that (just include the Jar as described below).



# Configuration

To be able to use the library you have two options, a dynamic and a static one. The difference between the two options is that
with dynamic you will *bundle* the library with your Matlab code, with the static one you will set the library one time globally
for the Matlab instance.

## Dynamic

To get started with the library just copy the downloaded jar into the folder holding your Matlab code file. At the top of your .m file just add following line:

```
javaaddpath('jcae_all-2.7.1.jar')
```

If you need to provide/set special Channel Access settings you need to create/provide a jcae.properties file in the same directory than your .m file. After creating this file you need to add following statement after the first `javaaddpath` call:

```
java.lang.System.setProperty('ch.psi.jcae.config.file', 'jcae.properties')
```

Regarding the possible settings inside the *jcae.properties* file please refer to the corresponding section of this [Readme.md](Readme.md). For Paul Scherrer Institute users there is a list of example configuration files for accessing the different facilities in [Environments.md](Environments.md).


In scripts that get executed several times in the same workspace use following construct to get rid of the Matlab warnings regarding re-adding to the classpath:

```matlab
if not(exist('java_classpath_set'))
    javaaddpath('jcae_all-2.7.1.jar')
    java.lang.System.setProperty('ch.psi.jcae.config.file', 'jcae.properties')
    java_classpath_set=1
end
```

In more complex Matlab projects you might not want to have the library in the same place as your matlab files but on a sub/parent-folder. In this case use relative paths to refer to the library.

```matlab
javaaddpath('../jcae_all-2.7.1.jar')
```

For Windows users, keep in mind to use backslashes in the path `\` !


## Static
To be able to use the package, include the full qualified path of the jar in the *javaclasspath.txt* within the Matlab home folder (ideally also copy the jar into this directory). For example:

```
/Users/ebner/Documents/MATLAB/jcae_all-2.7.1.jar
```

If you need to provide special Channel Access settings (e.g. special epics address list) you need to create/provide a jcae.properties file (e.g. in the Matlab home folder). Regarding the possible settings please refer to the corresponding section of this [Readme.md](Readme.md). After creating the file add following line into *java.opts* (also located in the Matlab home folder - create if it doesn't exist):

```
-Dch.psi.jcae.config.file=/Users/ebner/Documents/MATLAB/jcae.properties
```

_Note:_ For Paul Scherrer Institute users there is a list of example configuration files for accessing the different facilities in [Environments.md](Environments.md).

Note that similar to the jar it has to be the full qualified path of the file!

After creating/altering the file(s) *javaclasspath.txt* and *java.opts* you need to restart Matlab.



# Usage

After loading the required jar (see Overview above) channels can be created and read/written as follows:

```Matlab
import ch.psi.jcae.*
import ch.psi.jcae.impl.*
context = DefaultChannelService()
channel = context.createChannel(ChannelDescriptor('double', 'ARIDI-PCT:CURRENT'))
channel.getValue()
channel.destroy()
context.destroy()
```

Before being able to create channels there need to be a context / channel service instance. For normal setups, ideally there should be only one context per Matlab application. The context can be configured via the above mentioned jcae.properties file (in there you can specify for example the epics address list) that is passed via the _java.opts_ configuration line. To create a context use:

```Matlab
import ch.psi.jcae.*
import ch.psi.jcae.impl.*
context = DefaultChannelService()
```

The context need to be destroyed at the end of the application via

```Matlab
context.destroy()
```


To create a channel use the context createChannel function. The functions argument is a so called ChannelDescriptor which describes the desired channel, i.e. name, type, monitored (whether the channel object should be constantly monitoring the channel) as well as size (in case of array). 

Here are some examples on how to create channels:

```Matlab
% Create double channel
channel = context.createChannel(ChannelDescriptor('double', 'ARIDI-PCT:CURRENT'))
% Create monitored double channel
channel = context.createChannel(ChannelDescriptor('double', 'ARIDI-PCT:CURRENT', true))


% Create a channel for a double waveform/array - the size will be determined by the channel
channel = context.createChannel(ChannelDescriptor('double[]', 'ARIDI-PCT:CURRENT', true))
% Create a channel for a double waveform/array of specific size 10 
% If the actual channel array is bigger you specify you would only retrieve the first 10 elements
channel = context.createChannel(ChannelDescriptor('double[]', 'ARIDI-PCT:CURRENT', true, java.lang.Integer(10)))
```

Supported types are: `double`, `integer`, `short`, `float`, `byte`, `boolean`, `string` and the respective array forms `double[]`, `integer[]`, `int[]`, `short[]`, `float[]`, `byte[]`, `boolean[]`, `string[]` .

After creating a channel you are able to get and set values via the `getValue()` and `setValue(value)` methods. _Note_, if you created a channel with the monitored flag set true `getValue()` will not reach for the network to get the latest value of the channel but returns the latest update by a channel monitor.
If you require to explicitly fetch the value over the network use `getValue(true)` (this should only be rare cases as most of the time its enough to get the cached value)

`Note` a polling loop within your Matlab application on a channel created with the monitored flag set *true* is perfectly fine and does not induce any load on the network.


Beside the synchronous (i.e. blocking until the operation is done) versions of `getValue()` and `setValue(value)` there are also asynchronous calls. They are named `getValueAsync()` and `setValueAsync(value)`. Both functions immediately return with a handle for the opertation, i.e. a so called Future. The Future can be used to wait at any location in the script to wait for the completion of the operation and retrieve the final value of the channel.

Example asynchronous get:

```Matlab
future = channel.getValueAsync()
future_2 = channel_2.getValueAsync()

% do something different ...
do_something()
% ... or simply sleep ...
pause(10)
% ... or simply do nothing ...

value_channel = future.get()
value_channel_2 = future_2.get()
```

Example asynchronous put:

```Matlab
future = channel.setValueAsync(value_1) % this could, for example start some move of a motor ...
future_2 = channel_2.setValueAsync(value_2)

% do something different ...
do_something()
% ... or simply sleep ...
pause(10)
% ... or simply do nothing ...

future.get() % this will return the set value, i.e. value_1
future_2.get() % this will return the set value, i.e. value_2
```

Waiting for channels to reach a certain value can be done as follows:

```matlab
// Wait without timeout (i.e. forever)
channel.waitForValue('world')

// Wait with timeout
waitHandle = channel.waitForValueAsync('world').get(Long(10), java.util.concurrent.TimeUnit.SECONDS)
```

If you want to do stuff while waiting you can implement a busy loop like this:

```matlab
waitfuture = channel.waitForValueAsync('world')
while not(waitfuture.isDone())
    % do something
end
```

 
After you are done working with a channel close the channel via

```Matlab
channel.destroy()
```

There are various other ways to interact with a channel. However for more details on them have a look at the general [Readme.md](Readme.md).


## Annotations

Channels can be efficiently created in a one-go operation while using a Java class and Java annotations. To make use of this
create a Java class like follows:


```java
import ch.psi.jcae.annotation.CaChannel;
import ch.psi.jcae.Channel;

public class Channels {
        @CaChannel(name="${DEVICE}:CURRENT", type=Double.class, monitor=true)
        public Channel<String> current;
        @CaChannel(name="${DEVICE}:CUR-HOUR", type=Double.class, monitor=true)
        public Channel<String> currentHour;

        // Waveforms
        @CaChannel(name="${DEVICE}:WAVEFORM", type=int[].class, monitor=false)
        public Channel<int[]> value;
        // ...
}
```

After creating the file with all required channels you need to compile the file with `javac`. Therefore you need to switch to the commandline and execute following command:

```bash
javac -cp jcae_all-2.7.1.jar -source 1.7 -target 1.7 Channels.java
```

After compiling the class is ready to be used within Matlab. The channels can now be created as follows:


```matlab
javaaddpath('.')
channels = Channels()

import java.util.*
macros = HashMap()
macros.put('DEVICE','ARIDI-PCT')

context.createAnnotatedChannels(channels, macros)

channels.current.getValue()

context.destroyAnnotatedChannels(channels)
```

If no macros are used simply call for creating the channels:

```matlab
javaaddpath('.')
channels = Channels()
context.createAnnotatedChannels(channels)
```
