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
//  SuggestionsWebservice.m
//  General Services Administration
//


#import "SuggestionsWebservice.h"
#import "NSDictionary+NoNulls.h"
#import "MBMNetworkActivity.h"
#import "NSArray+NoNulls.h"
#import "JSON.h"

@implementation SuggestionsWebservice

+ (NSArray *)suggestionsWithKeyword:(NSString *)keyWord {
	
	NSURL *apiUrl = [NSURL URLWithString: [NSString stringWithFormat:@"%@?q=%@&aid=1176&app=true&api_key=%@&limit=15&timestamp=1276639015795&locale=en&m=false",USA_SEARCH_SAYT_ROOT, keyWord, API_KEY]];
	NSLog(@"apiUrl--%@",apiUrl);
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:apiUrl];
	
	[MBMNetworkActivity pushNetworkActivity];
	NSURLResponse *response = nil;
    NSError *error = nil;
	NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	if (error) {
        NSLog(@"Error: %@\n%@", error, [error userInfo]);
		[MBMNetworkActivity popNetworkActivity];
        return nil;
    }
	[request release];
	[MBMNetworkActivity popNetworkActivity];
	NSString *jsonString = [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease];
	
	if(jsonString) {
		if([jsonString length] > 1) {
			NSCharacterSet *chset = [NSCharacterSet	 characterSetWithCharactersInString:@"()"];
			jsonString = [jsonString stringByTrimmingCharactersInSet:chset];
		}
		return [self JSONValue:jsonString];
	} else {
		//NSLog(@"response string == null");
	}

	return nil;
	
}
+ (id)JSONValue:(NSString *)jsonString {
	id response = [jsonString JSONValue];
	if([response isKindOfClass:[NSDictionary class]] || [response isKindOfClass:[NSArray class]]) {
		return [response valueOmittingNullValues];
	}
	else {
		return response;
	}
}

@end
