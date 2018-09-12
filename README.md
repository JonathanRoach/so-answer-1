Stack Overflow Answer 1
=======================

This is the project used to prepare an answer for this [question](https://stackoverflow.com/questions/52140140/ping-through-host-array-and-show-results-in-table) about presenting result in a UITableView. The project shows the fix, and how UITableView's content's can be managed much more easily using ALTableViewHelper from ![Framework Central](https://frameworkcentral.com/static/home/img/logo-small.png) [here](https://frameworkcentral.com/frameworks/ALTableViewHelper/).

Installation
============

Clone the repository, or copy 'Stack Overflow TableView 1', which is the Xcode project. You will need the ![Framework Central](https://frameworkcentral.com/static/home/img/logo-small.png) application to build the project, which is [here](https://frameworkcentral.com/application/).

You will need to register, and then you can try any framework over two days of development before needing to pay for it. This is so you can try them out to see if they're what you need.

User Guide
==========

The application shows a simple example of managing a `UITableView`'s cells through `ALTableViewHelper`. The scenario is a list of URLs which are to be pinged to see if they work. The ping'ing is fake - after 3 seconds the result is predetermined - 2 successes then a fail regardless of the URL. The `UITableView` gets a new line for the ping's result. There is also a button to restart the ping sequence.

The reason for the application is to show how to simplify the code for managing the contents of a `UITableView` by using `ALTableViewHelper`.

Implementation
==============

Instead of inserting and deleting cells directly, a text description shows which cells should be in the view, and how they correspond to the contents of an array.

    serverStatusTable.setHelperString(
        "section\n" +
        " body\n" +
        "  serverStatusCell * serverStatusMain\n" +
        "   $.viewWithTag:(8).text <~ @[1] == 'error' ? 'Error ' : 'Running '\n" +
        "   $.viewWithTag:(7).image <~ @[1] == 'error' ? imageError : imageCheck \n" +
        "   $.viewWithTag:(2).text <~ componentTextArray[@[0]]\n" +
        "", context:self)

The string is a multi-line description, which is why each line ends `\n" +`. The string is:

    section
     body
      serverStatusCell * serverStatusMain
       $.viewWithTag:(8).text <~ @[1] == 'error' ? 'Error ' : 'Running'
       $.viewWithTag:(7).image <~ @[1] == 'error' ? imageError : imageCheck
       $.viewWithTag:(2).text <~ componentTextArray[@[0]]

When properties, eg `serverStatusMain`, are given, they are properties on `context:`, and the properties need to be `@objc` in Swift.

`section` shows the start of a `UITableView` section. You can add more sections - more about this later. `body` starts the list of cells inside the section - you can also set a `header` and `footer`. This part:

      serverStatusCell * serverStatusMain
       $.viewWithTag:(8).text <~ @[1] == 'error' ? 'Error ' : 'Running'
       $.viewWithTag:(7).image <~ @[1] == 'error' ? imageError : imageCheck
       $.viewWithTag:(2).text <~ componentTextArray[@[0]]

inserts `serverStatusCell` cells in the section. `* serverStatusMain` means there's a cell per element in the `serverStatusMain` array. If you want a single cell leave the `* blah` part out. If you want a number of cells `* 12`, or conditional `* showTheButton`, or the result of a calculation `* serverStatusMain |sort{ @ < $ }`, or any other calculation, which could be much more complex.

The 3 lines starting `$.viewWithTag:(...` bind the contents of the cell. `<~` is like `=`, only changes on the right cause an update - no need to make updates yourself. This is provided by `ALBind`, read more about it [here](https://frameworkcentral.com/frameworks/ALBind/). `$` is the cell and `@` is the value from the array. `viewWithTag:` is the selector for the function, which is why the `:` is there. 

When the array is a `NSMutableArray` changes to the array's contents are automatically reflected in the view's contents. This is what makes managing the `UITableView` very easy.

The `dataDelegate` is not set, and there are no methods to support it - this has been handled by the `ALTableViewHelper`.
