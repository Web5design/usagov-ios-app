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
//  SearchWebservice.m
//  General Services Administration
//

#import "SearchWebservice.h"
#import "NSString+UsaSearch.h"
#import "GSAAppAPI.h"


@implementation SearchWebservice

+ (NSData *)performSearchWithkeyword:(NSString *)query page:(int)pageNumber {
	
	NSString *urlString = [NSString stringWithFormat:@"query=%@&locale=en&m=true&format=json&affiliate=usagov&app=true&api_key=%@&hl=false&page=%d", [query stringByActuallyAddingURLEncoding], API_KEY ,pageNumber];
	NSLog(@"urlString- %@",urlString);
	NSData *searchResultData = [GSAAppAPI performSearchWithQueryString:urlString];
	
	return searchResultData;
}

+ (NSString *)performSearchForWebviewWithkeyword:(NSString *)query {
	
	NSString *urlString = [NSString stringWithFormat:@"commit=Search&format=html&show_searchbox=false&locale=en&m=true&query=%@", [query stringByActuallyAddingURLEncoding]];
	NSString *authorisedUrlString = [NSString stringWithFormat:@"%@?%@", USA_SEARCH_SEARCH_ROOT, urlString];
	NSLog(@"authorisedUrlString-%@",authorisedUrlString);
	return authorisedUrlString;
}

+ (NSData *)performImageSearchForWebviewWithkeyword:(NSString *)query page:(int)pageNumber {
	NSString *urlString = [NSString stringWithFormat:@"query=%@&locale=en&format=json&affiliate=usagov&app=true&api_key=%@&page=%d", [query stringByActuallyAddingURLEncoding], API_KEY, pageNumber];
	NSString *authorisedUrlString = [NSString stringWithFormat:@"%@?%@", USA_IMAGE_SEARCH_ROOT, urlString];
	NSLog(@"authorisedUrlString-%@",authorisedUrlString);
	[MBMNetworkActivity pushNetworkActivity];
	NSData *searchResultData = [NSData dataWithContentsOfURL:[NSURL URLWithString:authorisedUrlString]];
	[MBMNetworkActivity popNetworkActivity];
	return searchResultData;
}

+ (NSData *)performRecallSearchWithQueryString:(NSString *)query page:(int)pageNumber {
	//NSString *urlString = [NSString stringWithFormat:@"query=%@&locale=en&sort=date&format=json&affiliate=usagov&app=true&api_key=%@&page=%d", [query stringByActuallyAddingURLEncoding],API_KEY ,pageNumber];
    //Removing API key as we are using a new base URL for recall search
    NSString *urlString = [NSString stringWithFormat:@"query=%@&locale=en&sort=date&format=json&affiliate=usagov&app=true&page=%d", [query stringByActuallyAddingURLEncoding],pageNumber];
    
	NSString *authorisedUrlString = [NSString stringWithFormat:@"%@?%@", USA_SEARCH_RECALL_ROOT, urlString];
	NSLog(@"authorisedUrlString-%@",authorisedUrlString);
	[MBMNetworkActivity pushNetworkActivity];
	NSData *searchResultData = [NSData dataWithContentsOfURL:[NSURL URLWithString:authorisedUrlString]];
	[MBMNetworkActivity popNetworkActivity];
	
	return searchResultData;
}


@end
