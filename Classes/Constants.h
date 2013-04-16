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
//  Constants.h
//  General Services Administration
//


#import <Foundation/Foundation.h>

//#define API_KEY                 @"13b71018aea57ce42d4fbaea346306e7"
#define API_KEY                 @""
#define USA_SEARCH_SAYT_ROOT    @"http://search.usa.gov/sayt"
#define USA_SEARCH_SEARCH_ROOT  @"http://search.usa.gov/search"
#define USA_IMAGE_SEARCH_ROOT   @"http://search.usa.gov/search/images"
//#define USA_SEARCH_RECALL_ROOT  @"http://search.usa.gov/search/recalls"
#define USA_SEARCH_RECALL_ROOT  @"http://api.usa.gov/recalls/search.json"
#define WEBSITE_LINK            @"http://search.usa.gov/?locale=en&m=true"
#define BLOG_LINK               @"http://m.info.gov/6036"
#define PHONE_NUM               @"tel://+1-800-333-4636"

enum  {
	clearHistoryButtonTag = 1
};
enum {
    titleTag = 1,
    contentTag,
	deepLinkTag,
	urlTag,
	defaultTag,
	deeplinkTag,
	recallCompanyLabelTag,
	recallImageTag,
	recallNameLabelTag,
	recallTypeLabelTag,
	recallUnitLabelTag,
	recallDateLabelTag,
	searchHistoryLabelTag,
	searchHistoryImageTag,
	searchHistoryClearButtonTag,
	searchHistoryAccessoryImageTag
}labelTags;

enum  {
	imageTag1 = 1,
	imageTag2,
	imageTag3,
	imageTag4,
	imageTag5,
	imageTag6,
	imageTag7
}imageTags;

enum  {
	resultsSection = 0,
}sectionTags;

enum  {
	modeWebSearch = 1,
	modeImageSearch,
	modeRecallSearch
}searchModes;

enum {
	call = 1,
	message,
	visitBlogTag,
	visitSiteTag
	
};

#define imageHtml @"<html><head><meta content=\"text/html; charset=utf-8\" http-equiv=\"Content-Type\"><meta content=\"text/css\" http-equiv=\"Content-Style-Type\"><title></title><meta content=\"Cocoa HTML Writer\" name=\"Generator\"><meta content=\"1038.29\" name=\"CocoaVersion\"></head><body bgcolor=\"black\"><div align = center><img src=%@></div></body></html>"