The standard Debian installer disks are quite flexible in what options they
support, but much of these features require you to either manually type a
number of options at the bootloader prompt or do use a preseed config file.

The preseed config is quite easy to use in a large environment where you can
either control the boot network settings and serve up the preseed file.
However, even in that scenario, there is often not quite enough control of
the network environmet to be able to seamlessly configure the location of
the preseed.

There are multiple projects for building an entire Debian installer system
and there are several tutorials on how to edit an existing Debian installer
image, however I found it simpler to have a tool that I could use to make
minor changes to an existing installation CD image.

Specifically, this tool can append a new (or replacement) preseed config to
an existing installer image.
