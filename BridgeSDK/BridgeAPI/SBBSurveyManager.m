//
//  SBBSurveyManager.m
//  BridgeSDK
//
//  Created by Erin Mounts on 10/9/14.
//  Copyright (c) 2014 Sage Bionetworks. All rights reserved.
//

#import "SBBSurveyManager.h"
#import "SBBComponentManager.h"
#import "SBBAuthManager.h"
#import "SBBObjectManager.h"
#import "NSDate+SBBAdditions.h"

@implementation SBBSurveyManager

+ (instancetype)defaultComponent
{
  static SBBSurveyManager *shared;
  
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    shared = [self instanceWithRegisteredDependencies];
  });
  
  return shared;
}

- (NSURLSessionDataTask *)getSurveyByRef:(NSString *)ref completion:(SBBSurveyManagerGetCompletionBlock)completion
{
  NSMutableDictionary *headers = [NSMutableDictionary dictionary];
  [self.authManager addAuthHeaderToHeaders:headers];
  return [self.networkManager get:ref headers:headers parameters:nil completion:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
    id survey = [self.objectManager objectFromBridgeJSON:responseObject];
    if (completion) {
      completion(survey, error);
    }
  }];
}

- (NSURLSessionDataTask *)getSurveyByGuid:(NSString *)guid createdOn:(NSDate *)createdOn completion:(SBBSurveyManagerGetCompletionBlock)completion
{
  NSString *version = [createdOn ISO8601StringUTC];
  NSString *ref = [NSString stringWithFormat:@"/api/v1/surveys/%@/%@", guid, version];
  return [self getSurveyByRef:ref completion:completion];
}

- (NSURLSessionDataTask *)submitAnswers:(NSArray *)surveyAnswers toSurveyByRef:(NSString *)ref completion:(SBBSurveyManagerSubmitAnswersCompletionBlock)completion
{
  NSMutableDictionary *headers = [NSMutableDictionary dictionary];
  [self.authManager addAuthHeaderToHeaders:headers];
  id jsonAnswers = [self.objectManager bridgeJSONFromObject:surveyAnswers];
  return [self.networkManager post:ref headers:headers parameters:jsonAnswers completion:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
    id guidHolder = [self.objectManager objectFromBridgeJSON:responseObject];
    if (completion) {
      completion(guidHolder, error);
    }
  }];
}

- (NSURLSessionDataTask *)submitAnswers:(NSArray *)surveyAnswers toSurveyByGuid:(NSString *)guid createdOn:(NSDate *)createdOn completion:(SBBSurveyManagerSubmitAnswersCompletionBlock)completion
{
  NSString *version = [createdOn ISO8601StringUTC];
  NSString *ref = [NSString stringWithFormat:@"/api/v1/surveys/%@/%@", guid, version];
  return [self submitAnswers:surveyAnswers toSurveyByRef:ref completion:completion];
}

- (NSURLSessionDataTask *)getSurveyResponse:(NSString *)guid completion:(SBBSurveyManagerGetResponseCompletionBlock)completion
{
  NSMutableDictionary *headers = [NSMutableDictionary dictionary];
  [self.authManager addAuthHeaderToHeaders:headers];
  NSString *ref = [NSString stringWithFormat:@"/api/v1/surveys/response/%@", guid];
  return [self.networkManager get:ref headers:headers parameters:nil completion:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
    id surveyResponse = [self.objectManager objectFromBridgeJSON:responseObject];
    if (completion) {
      completion(surveyResponse, error);
    }
  }];
}

- (NSURLSessionDataTask *)addAnswers:(NSArray *)surveyAnswers toSurveyResponse:(NSString *)guid completion:(SBBSurveyManagerEditResponseCompletionBlock)completion
{
  NSMutableDictionary *headers = [NSMutableDictionary dictionary];
  [self.authManager addAuthHeaderToHeaders:headers];
  id jsonAnswers = [self.objectManager bridgeJSONFromObject:surveyAnswers];
  NSString *ref = [NSString stringWithFormat:@"/api/v1/surveys/response/%@", guid];
  return [self.networkManager post:ref headers:headers parameters:jsonAnswers completion:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
    if (completion) {
      completion(responseObject, error);
    }
  }];
}

- (NSURLSessionDataTask *)deleteSurveyResponse:(NSString *)guid completion:(SBBSurveyManagerEditResponseCompletionBlock)completion
{
  NSMutableDictionary *headers = [NSMutableDictionary dictionary];
  [self.authManager addAuthHeaderToHeaders:headers];
  NSString *ref = [NSString stringWithFormat:@"/api/v1/surveys/response/%@", guid];
  return [self.networkManager delete:ref headers:headers parameters:nil completion:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
    if (completion) {
      completion(responseObject, error);
    }
  }];
}

@end
