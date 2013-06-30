Storyboard segue generator
==========================

* Generate string constant for any segue with identifier and now you can use
```
[self performSegueWithIdentifier:self.segue.MySegue sender:nil];
```
```
-(void)prepareForSegue:( UIStoryboardSegue* )segue sender:( id )sender {
   if ( [segue.identifier isEqual:self.segue.MySegue] );
}
```
instead of
```
[self performSegueWithIdentifier:@"MySegue" sender:nil];
```
```
-(void)prepareForSegue:( UIStoryboardSegue* )segue sender:( id )sender {
   if ( [segue.identifier isEqual:@"MySegue"] );
}
```
* Gnerate string constant for TableViewCells with Identifiers. You can use
```
[self.tableView dequeueReusableCellWithIdentifier:self.cell.myTableViewCell];
```
instead of
```
[self.tableView dequeueReusableCellWithIdentifier:@"myTableViewCell"];
```

* Generate convenience constructors for view controller with Storyboard ID:
```
id controller = [MyViewController controllerMyViewController];
```

Install
-------

Download [ssgenerator.pkg](https://bitbucket.org/nut_code_monkey/ssgenerator/downloads/ssgenerator.pkg) and install.

Prepare Project
---------------

Go to Project -> Targets -> Add Build Phase -> Add Run Script:

![Add run script](https://bitbucket.org/nut_code_monkey/ssgenerator/downloads/add_run_script.png "Add run script")

Then insert sctipt:

![Generator script](https://bitbucket.org/nut_code_monkey/ssgenerator/downloads/generator_script.png "Generator script")

```bash 
ssgenerator -s Path/To/Storyboard.storyboard
```

Now use CMD+B shortcut to build your app. Add generated files to your project. By default file names is <Storyboard>Segue.h and <Storyboard>Segue.m
