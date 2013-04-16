/*
 * This project constitutes a work of the United States Government and is
 * not subject to domestic copyright protection under 17 USC § 105.
 *
 * However, because the project utilizes code licensed from contributors
 * and other third parties, it therefore is licensed under the MIT
 * License. http://opensource.org/licenses/mit-license.php. Under that
 * license, permission is granted free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the conditions that any appropriate copyright notices and this
 * permission notice are included in all copies or substantial portions
 * of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

//
//  ImageLoadOperation.m
//  General Services Administration
//


#import "ImageLoadOperation.h"
#import "MBMNetworkActivity.h"


@implementation ImageLoadOperation
@synthesize tableIndexPath;
@synthesize imageTag, mode;
@synthesize url;

- (id)initWithDelegate:(id<ImageLoadOperationDelegate>)obj indexPath:(NSIndexPath *)indexPath imageTag:(int)tag url:(NSString *)urlString mode:(int)pictueMode {
	[super init];
	delegate = obj;
	self.tableIndexPath = indexPath;
	self.imageTag = tag;
	self.url = urlString;
	self.mode = pictueMode;
	return self;
	
}

- (void)main {
	params = [[NSMutableArray alloc] init];
	[MBMNetworkActivity pushNetworkActivity];
	NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.url]];
	[MBMNetworkActivity popNetworkActivity];
	if ([self isCancelled]) { return; }
	if (data) {
		[params addObject:data];
	} else {
		NSLog(@"error catched");
		[params addObject:[[[NSData alloc] init] autorelease]];
	}
    
	
	if(self.tableIndexPath) {
		[params addObject:self.tableIndexPath];
	} else {
		[params addObject:@" "];
	}
    
	[params addObject:[NSString stringWithFormat:@"%d", self.imageTag]];
	if(self.mode == 1) {
		[delegate imageLoadOperationDidFinishWithImage:params];
	} else if(self.mode == 2){
		[delegate imageLoadOperationForScrollViewDidFinishWithImage:params];
	} else if(self.mode == 3){
		[delegate imageLoadOperationForLargeImageInScrollViewDidFinishWithImage:params];
	}
	[params release];
}


@end
