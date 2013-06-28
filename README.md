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

Download [ssgenerator.pkg](https://bitbucket.org/nut_code_monkey/ssgenerator/downloads/ssgenerator.pkg) and install.

Prepare Project
---------------

Go to Troject -> Targets -> Add Build Phase -> Add Run Script:

![Add run script](https://bitbucket.org/nut_code_monkey/ssgenerator/downloads/add_run_script.png "Add run script")

Then insert sctipt:

![Generator script](https://bitbucket.org/nut_code_monkey/ssgenerator/downloads/generator_script.png "Generator script")

```bash 
ssgenerator -s Path/To/Storyboard.storyboard
```
