Storyboard segue generator
==========================

*Generate string constant for any segues with identifier and now you can use
```
[self performSegueWithIdentifier:self.segues.MySegue sender:nil]
```
```
-(void)prepareForSegue:( UIStoryboardSegue* )segue sender:( id )sender {
   if ( [segue.identifier isEqual:self.segues.MySegue] )
       ...
}
```
instead
```
[self performSegueWithIdentifier:@"MySegue" sender:nil]
```
```
-(void)prepareForSegue:( UIStoryboardSegue* )segue sender:( id )sender {
   if ( [segue.identifier isEqual:@"MySegue"] )
       ...
}
```
*Gnerate string constant for TableViewCells with identifiers. You can use
```
[self.tableView dequeueReusableCellWithIdentifier:self.cells.myTableViewCell];
```
```
[self.tableView dequeueReusableCellWithIdentifier:@"myTableViewCell"];
```

*Generate convenience constructors for view controller with Storyboard ID:
```
id controller = [MyViewController controllerMyViewController];
```

Insall
------

Download [ssgenerator.pkg](https://github.com/nut-code-monkey/ssgenerator/ssgenerator.pkg) and install.

Prepare Project
---------------

Go to Troject -> Targets -> Add Build Phase -> Add Run Script:
![Add run script](/img/add_run_script.png "Add run script")

Then insert sctipt:
![Generator script](/img/generator_script.png "Generator script")
```bash 
ssgenerator -s Path/To/Storyboard.storyboard
```
