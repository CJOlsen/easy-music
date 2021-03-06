//
//  TableViewController.m
//  drivePod_foriOs5
//
//  Created by Christopher on 3/13/12.
//  Copyright (c) 2012,2013 Christopher Olsen. All rights reserved.
//

#import "TableViewController.h"


@implementation TableViewController

@synthesize delegate, playlist, theTableView, theToolbar;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self theTableView] setEditing:YES];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - TableView Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowsInSection = [playlist count];
    return rowsInSection;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    // Configure the cell...
    
    //get data for the cell
  
    NSString*songName = [[playlist.items objectAtIndex:[indexPath row]] valueForProperty:MPMediaItemPropertyTitle];
    NSString*artistName = [[playlist.items objectAtIndex:[indexPath row]] valueForProperty:MPMediaItemPropertyArtist];
    NSString*albumName = [[playlist.items objectAtIndex:[indexPath row]] valueForProperty:MPMediaItemPropertyAlbumTitle];
    [[cell textLabel] setText:[NSString stringWithFormat:@"%@", songName]];
    [[cell detailTextLabel] setText:[NSString stringWithFormat:@"%@ - %@", albumName, artistName]];
    
    cell.showsReorderControl = YES;
    
    return cell;
} 


-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"This is the playlist";
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) 
    {
        NSMutableArray*newPlaylistArray = [[NSMutableArray alloc] init];
        for (int i = 0; i < [playlist.items count]; i++)
        {
            if (i != [indexPath row])
            {
                [newPlaylistArray addObject:[playlist.items objectAtIndex:i]];
            }
        }
        MPMediaItemCollection*newPlaylist = [[MPMediaItemCollection alloc] initWithItems:newPlaylistArray];
        playlist = newPlaylist;
        [theTableView reloadData];
        
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert)//should never happen
    {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    } 
}


// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    // first of all, this method is at least twice as long as it needs to be, the two cases are really one,
    // just approached from different sides of the array.
    // second, it isn't entirely clear that this is *the* way to do this.  The issue is that the data is stored 
    // as a MPMediaItemCollection, which is 1)not mutable and 2) an Apple class that I don't want to mess with.
    // Since there isn't a method (that I know of) to move an object from here to there the entire thing needs to
    // be moved into a second container (NSMutableArray), then added back into a new MPMediaItemCollection.  Whether 
    // this should be done here, in the  ViewController class, or possibly in a different 'model' class to better 
    // follow the MVC paradigm is not entirely clear.  The current method is based on minimising the time the 
    // playlist is outside of its non-mutable apple-defined MPMediaItemCollection class, effectively quarantining
    // the break of the MVC ethic to this one method.
    
    NSMutableArray*newPlaylistArray = [[NSMutableArray alloc] init];
    
    //build the new list row by row based on moved item location/destination
    if ([fromIndexPath row] > [toIndexPath row])//moving an item to earlier in the list
    {
        int i;
        for (i = 0; i < ([toIndexPath row]); i++)
        {
            if (i != [toIndexPath row])
            {
                [newPlaylistArray addObject:[playlist.items objectAtIndex:i]];
            }
        }
        //insert the moved row    
        [newPlaylistArray addObject:[playlist.items objectAtIndex:[fromIndexPath row]]];
        int j;
        for (j = i + 1; j < [fromIndexPath row] + 1; j++)
        {
            [newPlaylistArray addObject:[playlist.items objectAtIndex:(j - 1)]];
        }
        for (int k = j; k < [playlist.items count]; k++)
        {
            [newPlaylistArray addObject:[playlist.items objectAtIndex:k]];
        }
    }
    else //moving an item to later in the list
    {
        int i;
        for (i = 0; i < ([fromIndexPath row]); i++)
        {
            [newPlaylistArray addObject:[playlist.items objectAtIndex:i]];
        }
        int j;
        for (j = i ; j < [toIndexPath row] ; j++)
        {
            [newPlaylistArray addObject:[playlist.items objectAtIndex:(j + 1)]];
        }
        //insert the moved row
        [newPlaylistArray addObject:[playlist.items objectAtIndex:[fromIndexPath row]]];
        for (int k = j + 1; k < [playlist.items count]; k++)
        {
            [newPlaylistArray addObject:[playlist.items objectAtIndex:k]];
        }
    }
    if ([newPlaylistArray count] > 0)
    {
        playlist = [[MPMediaItemCollection alloc] initWithItems:newPlaylistArray];
    }
    [theTableView reloadData];
}



// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}


#pragma mark - TableView Delegate

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - Toolbar Buttons

- (IBAction)clickSave:(id)sender 
{
    [self.delegate ModalTableViewDidClickDone:playlist];
}

- (IBAction)clickCancel:(id)sender 
{
    [self.delegate ModalTableViewDidClickCancel];
}
@end
