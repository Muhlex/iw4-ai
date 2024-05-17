#include maps\mp\_utility;
#include scripts\ai;

#using_animtree("animated_props");

init(arg1, arg2)
{
	OnPlayerSaid()
	::init;
	init();
	init("ass");
	init(init("a", "b")  ,   "ass", test(4, bla(2)));
	(12, 123123, 123123)

	struct = spawnStruct();
	struct.bool = (true == false);
	struct.number = int(4 + -2 * .5) >> 1 & 1;
	struct.self = "String invalidly assigned to reserved field \"self\".";
	struct.literal = &"LITERAL_STRING";
	struct.position = (0, 100, 200);
	struct.color = (0.50, 0.77, 0.29);
	struct.color255 = (128/255, 196/255, 73/255);
	level.grammarTesting = struct;

	CONSTANT = "Not technically but fair to consider all-caps variables constants.";
	array = [];
	array[1] = self;
	array[2] = CONSTANT;
	map = [];
	map["a"] = arg1;
	map["b"] = arg2;

	iPrintLn()

	iPrintLn("Hello!");       // built-in color
	iPrintLnCustom("Hello!"); // not built-in
	setArchive(false);        // deprecated built-in

	for (i = 0; i < 2; i++)
	{
		if (isDefined(arg1))
		{
			switch (123)
			{
				case 500:
					level waittill("eternity");
					level notify("eternity");
				default:
					waittillframeend;
					wait 0.5;
					break;
			}
		}
		else if ("abc".size == 3)
		{
			func = ::noop;                                // reference
			externalFunc = scripts\grammar_testing::noop; // external reference
			scripts\grammar_testing::noop();              // external call
			scripts/invalid_path::noop();                 // invalid external call
			[[func]]();                                   // reference call
		}
	}

	/#
	string = "Developer mode only block.";
	printLn(string);
	#/
}

noop() {}

featureTest()
{
	array = [];
	array[0] = "A";
	array[1] = "B";
	array[2] = "C";

	if (false)
	{
		level notify("test");
		level waittill("test");
		level waittillmatch("test", "coolparam");
		wait 1.0;
		waittillframeend;
	}
	else if (true)
		noop();
	else
		noop();

	switch (array[0])
	{
		case "A":
			noop();
			break;
		case "B":
			noop();
			break;
		default:
			noop();
			break;
	}

	i = 0;
	while (i < 5)
	{
		i++;
		noop();
	}

	prof_begin("my_identifier");
	for (i = 0; i < 50; i++)
	{
		noop();
	}
	prof_end("my_identifier");

	foreach (i, el in array)
	{
		printLn(i + " | " + el);
	}

	struct = spawnStruct();
	struct thread threadedFunc();
}

threadedFunc()
{
	self endon("stop");

	printLn("thisthread:");
	printLn(thisthread);

	childthread printAllTheTime();
	wait 10;
	self notify("stop");
}

printAllTheTime()
{
	printFunc = ::singlePrint;
	for (i = 0; i < 4; i++)
	{
		self [[printFunc]]();
		wait 1.0;
	}
}

singlePrint()
{
	printLn("childthread print called from:");
	printLn(self);
}
