//
//  RFRepository.m
//  Ratefinder
//
//  Created by Mikhail Kulichkov on 21/03/16.
//  Copyright © 2016 Epic Creators. All rights reserved.
//

#import "RFRepository.h"

static RFRepository *singleRepository = nil;

@implementation RFRepository


+(RFRepository *)sharedRepository {
    if (!singleRepository) {
        singleRepository = [[RFRepository alloc] init];
    }
    
    return singleRepository;
}


- (id)init
{
    self = [super init];
    
    RFPerson *person1 = [[RFPerson alloc] init];
    person1.identificator = 1;
    person1.name = @"Путин Владимир Владимирович";
    
    RFPerson *person2 = [[RFPerson alloc] init];
    person2.identificator = 2;
    person2.name = @"Медведев Дмитрий Анатольевич";
    
    RFPerson *person3 = [[RFPerson alloc] init];
    person3.identificator = 3;
    person3.name = @"Навальный Алексей Анатольевич";
    
    RFPerson *person4 = [[RFPerson alloc] init];
    person4.identificator = 4;
    person4.name = @"Жириновский Владимир Вольфович";
    
    self.persons = [NSArray arrayWithObjects: person1, person2, person3, person4, nil];
    
    RFSite *site1 = [[RFSite alloc] init];
    site1.identificator = 1;
    site1.name = @"lenta.ru";
    
    RFSite *site2 = [[RFSite alloc] init];
    site2.identificator = 2;
    site2.name = @"gazeta.ru";
    
    RFSite *site3 = [[RFSite alloc] init];
    site3.identificator = 3;
    site3.name = @"vesti.ru";
    
    RFSite *site4 = [[RFSite alloc] init];
    site4.identificator = 4;
    site4.name = @"ria.ru";
    
    self.sites = [NSArray arrayWithObjects: site1, site2, site3, site4, nil];
    
    return self;
}

- (NSArray *)getRatesOnSite: (int)siteID
{
    NSMutableArray *ratesOnSite = [NSMutableArray array];
    
    for (RFPerson *person in self.persons) {
        RFPersonWithRate *personWithRate = [[RFPersonWithRate alloc] init];
        personWithRate.person = person;
        personWithRate.rate = 100*arc4random();
        [ratesOnSite addObject:personWithRate];
    }
    
    return ratesOnSite;
}

@end
