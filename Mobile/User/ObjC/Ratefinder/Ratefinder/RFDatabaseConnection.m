//
//  RFDatabaseConnection.m
//  Ratefinder
//
//  Created by Mikhail Kulichkov on 28/03/16.
//  Copyright © 2016 Epic Creators. All rights reserved.
//

#import "RFDatabaseConnection.h"

static RFDatabaseConnection *singleDatabaseConnection;


@implementation RFDatabaseConnection
{
    NSArray *parsedJSONArray;
}

+(RFDatabaseConnection *) defaultDatabaseConnection
{
    if (!singleDatabaseConnection) {
        singleDatabaseConnection = [[RFDatabaseConnection alloc] init];
        singleDatabaseConnection->parsedJSONArray = nil;
    }
    
    return singleDatabaseConnection;
}


- (void) parseJSONData: (NSData *)data andSelector:(SEL)theSelector
{
    
    NSString *stringJSON = [[NSString alloc] initWithData:data encoding:NSISOLatin1StringEncoding];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\s+<!--.*$"
                                                                           options:NSRegularExpressionDotMatchesLineSeparators
                                                                             error:nil];
    NSTextCheckingResult *result = [regex firstMatchInString:stringJSON
                                                     options:0
                                                       range:NSMakeRange(0, stringJSON.length)];
    if(result) {
        NSRange range = [result rangeAtIndex:0];
        stringJSON = [stringJSON stringByReplacingCharactersInRange:range withString:@""];
        NSLog(@"json: %@", stringJSON);
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        NSData *jsonData = [stringJSON dataUsingEncoding:NSUTF8StringEncoding];
        parsedJSONArray = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
        
        // Selector is one but data is another
                
        if (theSelector == @selector(getSites)) {
            [self.delegate sitesDidRecieveWithObject:parsedJSONArray];
        } else if (theSelector == @selector(getPersons)) {
            [self.delegate personsDidRecieveWithObject:parsedJSONArray];
        } else if (theSelector == @selector(getPersonsWithRatesOnSite:)) {
            [self.delegate personsWithRatesDidRecieveWithObject:parsedJSONArray];
        } else if (theSelector == @selector(getRatesOfPerson:onSite:from:to:)) {
            [self.delegate ratesWithDatesDidRecieveWithObject:parsedJSONArray];
        }
    });
    
}

-(void)getDataFromURL: (NSURL *)theURL andSelector:(SEL)theSelector
{
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:theURL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [self parseJSONData:data andSelector:theSelector];
    }];
    [dataTask resume];
}

-(void)getSites
{
    NSURL *sitesURL = [NSURL URLWithString: @"http://kulichkov.netne.net/sites.php"];
    [self getDataFromURL:sitesURL andSelector:@selector(getSites)];
}

-(void)getPersons
{
    NSURL *personsURL = [NSURL URLWithString: @"http://kulichkov.netne.net/persons.php"];
    [self getDataFromURL:personsURL andSelector:@selector(getPersons)];
}

-(void)getPersonsWithRatesOnSite: (int)siteID
{
    NSString *stringURL = [NSString stringWithFormat:@"http://kulichkov.netne.net/rates.php?siteID=%d", siteID];
    NSURL *PersonsWithRatesOnSiteURL = [NSURL URLWithString: stringURL];
    [self getDataFromURL:PersonsWithRatesOnSiteURL andSelector:@selector(getPersonsWithRatesOnSite:)] ;
    //NSLog(@"%@", parsedJSONArray);
}

-(void)getRatesOfPerson:(int)personID onSite:(int)siteID from:(NSDate *)startDate to:(NSDate *)finishDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    NSString *stringStartDate = [dateFormatter stringFromDate:startDate];
    NSString *stringFinishDate = [dateFormatter stringFromDate:finishDate];
    NSString *stringURL = [NSString stringWithFormat:@"http://kulichkov.netne.net/rateswithdates.php?siteID=%d&personID=%d&startDate=%@&finishDate=%@", siteID, personID, stringStartDate, stringFinishDate];
    NSURL *PersonsWithRatesOnSiteURL = [NSURL URLWithString: stringURL];
    [self getDataFromURL:PersonsWithRatesOnSiteURL andSelector:@selector(getRatesOfPerson:onSite:from:to:)];
}




@end
