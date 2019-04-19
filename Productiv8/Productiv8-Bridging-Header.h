//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

// As per: https://github.com/google/google-api-objectivec-client/issues/221#issuecomment-318132385
//   The issue is likely the use of a Swift bridging header. Sadly, bridging headers will strip all properties,
//   methods, etc. that reference an "incomplete" type. Incomplete is caused simply by things being forward
//   declared (@Class Foo, @protocol DoSomething). To have the properties exposed, you have to manually import
//   the header that define the forward declared types:
//
//   Try adding:
//   #import <GTMSessionFetcher/GTMSessionFetcher.h>
//   #import <GTMSessionFetcher/GTMSessionFetcherService.h>

#import <GTMSessionFetcher/GTMSessionFetcher.h>
#import <GTMSessionFetcher/GTMSessionFetcherService.h>
