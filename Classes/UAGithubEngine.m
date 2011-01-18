//
//  UAGithubEngine.m
//  UAGithubEngine
//
//  Created by Owain Hunt on 02/04/2010.
//  Copyright 2010 Owain R Hunt. All rights reserved.
//

#import "UAGithubEngine.h"

#import "UAGithubSimpleJSONParser.h"
#import "UAGithubUsersJSONParser.h"
#import "UAGithubRepositoriesJSONParser.h"
#import "UAGithubCommitsJSONParser.h"
#import "UAGithubIssuesJSONParser.h"
#import "UAGithubIssueCommentsJSONParser.h"
#import "CJSONDeserializer.h"

#import "UAGithubEngineRequestTypes.h"
#import "UAGithubURLConnection.h"

#import "NSString+UAGithubEngineUtilities.h"
#import "NSData+Base64.h"

#define API_PROTOCOL @"https://"
#define API_DOMAIN @"github.com/api"
#define API_VERSION @"v2"
#define API_FORMAT @"json"


@interface UAGithubEngine (Private)

- (NSString *)sendRequest:(NSString *)path requestType:(UAGithubRequestType)requestType responseType:(UAGithubResponseType)responseType withParameters:(NSDictionary *)params;
- (BOOL)isValidSelectorForDelegate:(SEL)selector;

@end


@implementation UAGithubEngine

@synthesize delegate, username, password, connections;


#pragma mark Initializer

- (id)initWithUsername:(NSString *)aUsername password:(NSString *)aPassword delegate:(id)theDelegate
{
	if (self = [super init]) 
	{
		username = [aUsername retain];
		password = [aPassword retain];
		delegate = theDelegate;
		connections = [[NSMutableDictionary alloc] initWithCapacity:0];
	}
	
	return self;
		
}


- (void)dealloc
{
	[username release];
	[password release];
	[connections release];
	delegate = nil;
	
	[super dealloc];
	
}


#pragma mark Delegate Check

- (BOOL)isValidSelectorForDelegate:(SEL)selector
{
	return ((delegate != nil) && [delegate respondsToSelector:selector]);
}


#pragma mark Request Management

- (NSString *)sendRequest:(NSString *)path requestType:(UAGithubRequestType)requestType responseType:(UAGithubResponseType)responseType withParameters:(NSDictionary *)params
{
	
	NSMutableString *querystring = nil;
	if ([params count] > 0) 
	{
		querystring = [NSMutableString stringWithString:@"?"];
		for (NSString *key in [params allKeys]) 
		{
			[querystring appendFormat:@"%@%@=%@", [querystring length] == 1 ? @"" : @"&", key, [[params valueForKey:key] encodedString]];
		}
	}
	
	NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@/%@/%@/%@", API_PROTOCOL, API_DOMAIN, API_VERSION, API_FORMAT, path];
	
	if ([querystring length] > 0)
	{
		[urlString appendString:querystring];
	}
	 
	
	NSURL *theURL = [NSURL URLWithString:urlString];
	
	NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:theURL cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:30];
	[urlRequest setValue:[NSString stringWithFormat:@"Basic %@", [[[NSString stringWithFormat:@"%@:%@", self.username, self.password] dataUsingEncoding:NSUTF8StringEncoding] base64EncodedString]] forHTTPHeaderField:@"Authorization"];	
	
	switch (requestType) {
		case UAGithubRepositoryUpdateRequest:
		case UAGithubRepositoryCreateRequest:
		case UAGithubRepositoryDeleteConfirmationRequest:
		case UAGithubDeployKeyAddRequest:
		case UAGithubDeployKeyDeleteRequest:
		case UAGithubCollaboratorAddRequest:
		case UAGithubCollaboratorRemoveRequest:
		case UAGithubIssueCommentAddRequest:
		{
			[urlRequest setHTTPMethod:@"POST"];
		}
			break;
		default:
			break;
	}
	
	UAGithubURLConnection *connection;
	connection = [[UAGithubURLConnection alloc] initWithRequest:urlRequest delegate:self requestType:requestType responseType:responseType];
	
	if (!connection) 
	{
		return nil;
	}
	else
	{ 
		[connections setObject:connection forKey:connection.identifier];
		[connection release];
	}
	
	return connection.identifier;
	
}


- (void)parseDataForConnection:(UAGithubURLConnection *)connection
{
	switch (connection.responseType) {
		case UAGithubRepositoriesResponse:
		case UAGithubRepositoryResponse:
			[[UAGithubRepositoriesJSONParser alloc] initWithJSON:connection.data delegate:self connectionIdentifier:connection.identifier requestType:connection.requestType responseType:connection.responseType];
			break;
		case UAGithubIssuesResponse:
		case UAGithubIssueResponse:
			[[UAGithubIssuesJSONParser alloc] initWithJSON:connection.data delegate:self connectionIdentifier:connection.identifier requestType:connection.requestType responseType:connection.responseType];
			break;
		case UAGithubIssueCommentsResponse:
		case UAGithubIssueCommentResponse:
			[[UAGithubIssueCommentsJSONParser alloc] initWithJSON:connection.data delegate:self connectionIdentifier:connection.identifier requestType:connection.requestType responseType:connection.responseType];
			break;
		case UAGithubUsersResponse:
		case UAGithubUserResponse:
			[[UAGithubUsersJSONParser alloc] initWithJSON:connection.data delegate:self connectionIdentifier:connection.identifier requestType:connection.requestType responseType:connection.responseType];
			break;
		case UAGithubCommitsResponse:
		case UAGithubCommitResponse:
			[[UAGithubCommitsJSONParser alloc] initWithJSON:connection.data delegate:self connectionIdentifier:connection.identifier requestType:connection.requestType responseType:connection.responseType];
			break;
		case UAGithubRawBlobResponse:
			[delegate rawBlobReceived:connection.data forConnection:connection.identifier];
			break;
		case UAGithubCollaboratorsResponse:
		case UAGithubBlobsResponse:
		case UAGithubBlobResponse:
		case UAGithubIssueLabelsResponse:
		case UAGithubRepositoryLabelsResponse:
		case UAGithubDeployKeysResponse:
		case UAGithubRepositoryLanguageBreakdownResponse:
		case UAGithubTagsResponse:
		case UAGithubBranchesResponse:
		case UAGithubTreeResponse:
			[[UAGithubSimpleJSONParser alloc] initWithJSON:connection.data delegate:self connectionIdentifier:connection.identifier requestType:connection.requestType responseType:connection.responseType];
			break;
		default:
			break;
	}

}
	

#pragma mark Parser Delegate Methods

- (void)parsingSucceededForConnection:(NSString *)connectionIdentifier ofResponseType:(UAGithubResponseType)responseType withParsedObjects:(NSArray *)parsedObjects
{
	
	switch (responseType) {
		case UAGithubRepositoriesResponse:
		case UAGithubRepositoryResponse:
			[delegate repositoriesReceived:parsedObjects forConnection:connectionIdentifier];
			break;
		case UAGithubIssuesResponse:
		case UAGithubIssueResponse:
			[delegate issuesReceived:parsedObjects forConnection:connectionIdentifier];
			break;
		case UAGithubIssueCommentsResponse:
		case UAGithubIssueCommentResponse:
			[delegate issueCommentsReceived:parsedObjects forConnection:connectionIdentifier];
			break;
		case UAGithubUsersResponse:
		case UAGithubUserResponse:
			[delegate usersReceived:parsedObjects forConnection:connectionIdentifier];
			break;
		case UAGithubIssueLabelsResponse:
		case UAGithubRepositoryLabelsResponse:
			[delegate labelsReceived:parsedObjects forConnection:connectionIdentifier];
			break;
		case UAGithubCommitsResponse:
		case UAGithubCommitResponse:
			[delegate commitsReceived:parsedObjects forConnection:connectionIdentifier];
			break;
		case UAGithubBlobsResponse:
			[delegate blobsReceieved:parsedObjects forConnection:connectionIdentifier];
			break;
		case UAGithubBlobResponse:
			[delegate blobReceived:parsedObjects forConnection:connectionIdentifier];
			break;
		case UAGithubCollaboratorsResponse:
			[delegate collaboratorsReceived:parsedObjects forConnection:connectionIdentifier];
			break;
		case UAGithubDeployKeysResponse:
			[delegate deployKeysReceived:parsedObjects forConnection:connectionIdentifier];
			break;
		case UAGithubRepositoryLanguageBreakdownResponse:
			[delegate languagesReceived:parsedObjects forConnection:connectionIdentifier];
			break;
		case UAGithubTagsResponse:
			[delegate tagsReceived:parsedObjects forConnection:connectionIdentifier];
			break;
		case UAGithubBranchesResponse:
			[delegate branchesReceived:parsedObjects forConnection:connectionIdentifier];
			break;
		case UAGithubTreeResponse:
			[delegate treeReceived:parsedObjects forConnection:connectionIdentifier];
			break;
		default:
			break;
	}
	
}


- (void)parsingFailedForConnection:(NSString *)connectionIdentifier ofResponseType:(UAGithubResponseType)responseType withError:(NSError *)parseError
{
	[delegate requestFailed:connectionIdentifier withError:parseError];	
}


#pragma mark Repositories

- (NSString *)getRepositoriesForUser:(NSString *)aUser includeWatched:(BOOL)watched
{
	return [self sendRequest:[NSString stringWithFormat:@"repos/%@/%@", (watched ? @"watched" : @"show"), aUser] requestType:UAGithubRepositoriesRequest responseType:UAGithubRepositoriesResponse withParameters:nil];	
}


- (NSString *)getRepository:(NSString *)repositoryPath;
{
	return [self sendRequest:[NSString stringWithFormat:@"repos/show/%@", repositoryPath] requestType:UAGithubRepositoryRequest responseType:UAGithubRepositoryResponse withParameters:nil];	
}


- (NSString *)searchRepositories:(NSString *)query
{
	return [self sendRequest:[NSString stringWithFormat:@"repos/search/%@", [query encodedString]] requestType:UAGithubRepositoriesRequest responseType:UAGithubRepositoriesResponse withParameters:nil];	 
}


- (NSString *)updateRepository:(NSString *)repositoryPath withInfo:(NSDictionary *)infoDictionary
{
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
	for (NSString *key in [infoDictionary allKeys])
	{
		[params setObject:[infoDictionary objectForKey:key] forKey:[NSString stringWithFormat:@"values[%@]", key]];
		
	}
	
	return [self sendRequest:[NSString stringWithFormat:@"repos/show/%@", repositoryPath] requestType:UAGithubRepositoryUpdateRequest responseType:UAGithubRepositoryResponse withParameters:params];
	
}


- (NSString *)watchRepository:(NSString *)repositoryPath
{
	return [self sendRequest:[NSString stringWithFormat:@"repos/watch/%@", repositoryPath] requestType:UAGithubRepositoryWatchRequest responseType:UAGithubRepositoryResponse withParameters:nil];	 
}


- (NSString *)unwatchRepository:(NSString *)repositoryPath
{
	return [self sendRequest:[NSString stringWithFormat:@"repos/unwatch/%@", repositoryPath] requestType:UAGithubRepositoryUnwatchRequest responseType:UAGithubRepositoryResponse withParameters:nil];
}


- (NSString *)forkRepository:(NSString *)repositoryPath
{
	return [self sendRequest:[NSString stringWithFormat:@"repos/fork/%@", repositoryPath] requestType:UAGithubRepositoryForkRequest responseType:UAGithubRepositoryResponse withParameters:nil];
}


- (NSString *)createRepositoryWithInfo:(NSDictionary *)infoDictionary
{
	return [self sendRequest:@"repos/create" requestType:UAGithubRepositoryCreateRequest responseType:UAGithubRepositoryResponse withParameters:infoDictionary];	
}


- (NSString *)deleteRepository:(NSString *)repositoryName
{
	return [self sendRequest:[NSString stringWithFormat:@"repos/delete/%@", repositoryName] requestType:UAGithubRepositoryDeleteRequest responseType:UAGithubDeleteRepositoryResponse withParameters:nil];
}


- (NSString *)confirmDeletionOfRepository:(NSString *)repositoryName withToken:(NSString *)deleteToken
{
	NSDictionary *params = [NSDictionary dictionaryWithObject:deleteToken forKey:@"delete_token"];
	return [self sendRequest:[NSString stringWithFormat:@"repos/delete/%@", repositoryName] requestType:UAGithubRepositoryDeleteConfirmationRequest responseType:UAGithubDeleteRepositoryConfirmationResponse withParameters:params];
	
}


- (NSString *)privatiseRepository:(NSString *)repositoryName
{
	return [self sendRequest:[NSString stringWithFormat:@"repos/set/private/%@", repositoryName] requestType:UAGithubRepositoryPrivatiseRequest responseType:UAGithubRepositoryResponse withParameters:nil];	
}


- (NSString *)publiciseRepository:(NSString *)repositoryName
{
	return [self sendRequest:[NSString stringWithFormat:@"repos/set/public/%@", repositoryName] requestType:UAGithubRepositoryPubliciseRequest responseType:UAGithubRepositoryResponse withParameters:nil];
}


- (NSString *)getDeployKeysForRepository:(NSString *)repositoryName
{
	return [self sendRequest:[NSString stringWithFormat:@"repos/keys/%@", repositoryName] requestType:UAGithubDeployKeysRequest responseType:UAGithubDeployKeysResponse withParameters:nil];
}


- (NSString *)addDeployKey:(NSString *)keyData withTitle:(NSString *)keyTitle ToRepository:(NSString *)repositoryName
{
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:keyData, @"key", keyTitle, @"title", nil];
	return [self sendRequest:[NSString stringWithFormat:@"repos/key/%@/add", repositoryName] requestType:UAGithubDeployKeyAddRequest responseType:UAGithubDeployKeysResponse withParameters:params];

}


- (NSString *)removeDeployKey:(NSString *)keyID fromRepository:(NSString *)repositoryName
{
	NSDictionary *params = [NSDictionary dictionaryWithObject:keyID forKey:@"id"];
	return [self sendRequest:[NSString stringWithFormat:@"repos/key/%@/remove", repositoryName] requestType:UAGithubDeployKeyDeleteRequest responseType:UAGithubDeployKeysResponse withParameters:params];

}


- (NSString *)getCollaboratorsForRepository:(NSString *)repositoryPath
{
	return [self sendRequest:[NSString stringWithFormat:@"repos/show/%@/collaborators", repositoryPath] requestType:UAGithubCollaboratorsRequest responseType:UAGithubCollaboratorsResponse withParameters:nil];	
}


- (NSString *)addCollaborator:(NSString *)collaborator toRepository:(NSString *)repositoryName
{
	return [self sendRequest:[NSString stringWithFormat:@"repos/collaborators/%@/add/%@", repositoryName, collaborator] requestType:UAGithubCollaboratorAddRequest responseType:UAGithubCollaboratorsResponse withParameters:nil];
}


- (NSString *)removeCollaborator:(NSString *)collaborator fromRepository:(NSString *)repositoryName
{
	return [self sendRequest:[NSString stringWithFormat:@"repos/collaborators/%@/remove/%@", repositoryName, collaborator] requestType:UAGithubCollaboratorRemoveRequest responseType:UAGithubCollaboratorsResponse withParameters:nil];
}


- (NSString *)getPushableRepositories
{
	return [self sendRequest:@"repos/pushable" requestType:UAGithubRepositoriesRequest responseType:UAGithubRepositoriesResponse withParameters:nil];	
}


- (NSString *)getNetworkForRepository:(NSString *)repositoryPath
{
	return [self sendRequest:[NSString stringWithFormat:@"repos/show/%@/network", repositoryPath] requestType:UAGithubRepositoriesRequest responseType:UAGithubRepositoriesResponse withParameters:nil];	
}


- (NSString *)getLanguageBreakdownForRepository:(NSString *)repositoryPath
{
	return [self sendRequest:[NSString stringWithFormat:@"repos/show/%@/languages", repositoryPath] requestType:UAGithubRepositoryLanguageBreakdownRequest responseType:UAGithubRepositoryLanguageBreakdownResponse withParameters:nil];	
}


- (NSString *)getTagsForRepository:(NSString *)repositoryPath
{
	return [self sendRequest:[NSString stringWithFormat:@"repos/show/%@/tags", repositoryPath] requestType:UAGithubTagsRequest responseType:UAGithubTagsResponse withParameters:nil];	
}


- (NSString *)getBranchesForRepository:(NSString *)repositoryPath
{
	return [self sendRequest:[NSString stringWithFormat:@"repos/show/%@/branches", repositoryPath] requestType:UAGithubBranchesRequest responseType:UAGithubBranchesResponse withParameters:nil];	
}


#pragma mark Issues 

- (NSString *)getIssuesForRepository:(NSString *)repositoryPath withRequestType:(UAGithubRequestType)requestType
{
	// Use UAGithubIssuesOpenRequest for open issues, UAGithubIssuesClosedRequest for closed issues

	switch (requestType) {
		case UAGithubIssuesOpenRequest:
			return [self sendRequest:[NSString stringWithFormat:@"issues/list/%@/open", repositoryPath] requestType:UAGithubIssuesOpenRequest responseType:UAGithubIssuesResponse withParameters:nil];
			break;
		case UAGithubIssuesClosedRequest:
			return [self sendRequest:[NSString stringWithFormat:@"issues/list/%@/closed", repositoryPath] requestType:UAGithubIssuesClosedRequest responseType:UAGithubIssuesResponse withParameters:nil];
			break;
		default:
			break;
	}
	return nil;
}


- (NSString *)getIssue:(NSString *)issuePath
{
	return [self sendRequest:[NSString stringWithFormat:@"issues/show/%@", issuePath] requestType:UAGithubIssueRequest responseType:UAGithubIssueResponse withParameters:nil];	
}


- (NSString *)editIssue:(NSString *)issuePath withDictionary:(NSDictionary *)issueDictionary
{
	return [self sendRequest:[NSString stringWithFormat:@"issues/edit/%@", issuePath] requestType:UAGithubIssueEditRequest responseType:UAGithubIssueResponse withParameters:issueDictionary];	
}


- (NSString *)addIssueForRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)issueDictionary
{
	return [self sendRequest:[NSString stringWithFormat:@"issues/open/%@", repositoryPath] requestType:UAGithubIssueAddRequest responseType:UAGithubIssueResponse withParameters:issueDictionary];	
}


- (NSString *)closeIssue:(NSString *)issuePath
{
	return [self sendRequest:[NSString stringWithFormat:@"issues/close/%@", issuePath] requestType:UAGithubIssueCloseRequest responseType:UAGithubIssueResponse withParameters:nil];	
}


- (NSString *)reopenIssue:(NSString *)issuePath
{
	return [self sendRequest:[NSString stringWithFormat:@"issues/reopen/%@", issuePath] requestType:UAGithubIssueReopenRequest responseType:UAGithubIssueResponse withParameters:nil];	
}


#pragma mark Labels

- (NSString *)getLabelsForRepository:(NSString *)repositoryPath
{
	return [self sendRequest:[NSString stringWithFormat:@"issues/labels/%@", repositoryPath] requestType:UAGithubRepositoryLabelsRequest responseType:UAGithubRepositoryLabelsResponse withParameters:nil];	
}


- (NSString *)addLabel:(NSString *)label toRepository:(NSString *)repositoryPath
{
	return [self sendRequest:[NSString stringWithFormat:@"issues/label/add/%@/%@", repositoryPath, [label encodedString]] requestType:UAGithubRepositoryLabelAddRequest responseType:UAGithubIssueLabelsResponse withParameters:nil];	
}


- (NSString *)removeLabel:(NSString *)label fromRepository:(NSString *)repositoryPath
{
	return [self sendRequest:[NSString stringWithFormat:@"issues/label/remove/%@/%@", repositoryPath, [label encodedString]] requestType:UAGithubRepositoryLabelRemoveRequest responseType:UAGithubIssueLabelsResponse withParameters:nil];	
}


- (NSString *)addLabel:(NSString *)label toIssue:(NSInteger)issueNumber inRepository:(NSString *)repositoryPath
{
	return [self sendRequest:[NSString stringWithFormat:@"issues/label/add/%@/%@/%d", repositoryPath, [label encodedString], issueNumber] requestType:UAGithubIssueLabelAddRequest responseType:UAGithubIssueLabelsResponse withParameters:nil];	
}


- (NSString *)removeLabel:(NSString *)label fromIssue:(NSInteger)issueNumber inRepository:(NSString *)repositoryPath
{
	return [self sendRequest:[NSString stringWithFormat:@"issues/label/remove/%@/%@/%d", repositoryPath, [label encodedString], issueNumber] requestType:UAGithubIssueLabelRemoveRequest responseType:UAGithubIssueLabelsResponse withParameters:nil];	
}


#pragma mark Comments

- (NSString *)getCommentsForIssue:(NSString *)issuePath
{
	return [self sendRequest:[NSString stringWithFormat:@"issues/comments/%@", issuePath] requestType:UAGithubIssueCommentsRequest responseType:UAGithubIssueCommentsResponse withParameters:nil];	
}


- (NSString *)addComment:(NSString *)comment toIssue:(NSString *)issuePath
{
	NSDictionary *commentDictionary = [NSDictionary dictionaryWithObject:comment forKey:@"comment"];
	return [self sendRequest:[NSString stringWithFormat:@"issues/comment/%@", issuePath] requestType:UAGithubIssueCommentAddRequest responseType:UAGithubIssueCommentResponse withParameters:commentDictionary];
	
}


#pragma mark Users

- (NSString *)getUser:(NSString *)user
{
	return [self sendRequest:[NSString stringWithFormat:@"user/show/%@", user] requestType:UAGithubUserRequest responseType:UAGithubUserResponse withParameters:nil];	
}


- (NSString *)searchUsers:(NSString *)query byEmail:(BOOL)email
{
	return [self sendRequest:[NSString stringWithFormat:@"user/%@/%@", email ? @"email" : @"search", query] requestType:UAGithubUserRequest responseType:UAGithubUsersResponse withParameters:nil];	
}


#pragma mark Commits

- (NSString *)getCommitsForBranch:(NSString *)branchPath
{
	return [self sendRequest:[NSString stringWithFormat:@"commits/list/%@", branchPath] requestType:UAGithubCommitsRequest responseType:UAGithubCommitsResponse withParameters:nil];	
}


- (NSString *)getCommit:(NSString *)commitPath
{
	return [self sendRequest:[NSString stringWithFormat:@"commits/show/%@", commitPath] requestType:UAGithubCommitRequest responseType:UAGithubCommitResponse withParameters:nil];	
}
	

#pragma mark Trees

- (NSString *)getTree:(NSString *)treePath
{
	return [self sendRequest:[NSString stringWithFormat:@"tree/show/%@", treePath] requestType:UAGithubTreeRequest responseType:UAGithubTreeResponse withParameters:nil];	
}


#pragma mark Blobs

- (NSString *)getBlobsForSHA:(NSString *)shaPath
{
	return [self sendRequest:[NSString stringWithFormat:@"blob/all/%@", shaPath] requestType:UAGithubBlobsRequest responseType:UAGithubBlobsResponse withParameters:nil];	
}


- (NSString *)getBlob:(NSString *)blobPath
{
	return [self sendRequest:[NSString stringWithFormat:@"blob/show/%@", blobPath] requestType:UAGithubBlobRequest responseType:UAGithubBlobResponse withParameters:nil];	
}


- (NSString *)getRawBlob:(NSString *)blobPath
{
	return [self sendRequest:[NSString stringWithFormat:@"blob/show/%@", blobPath] requestType:UAGithubRawBlobRequest responseType:UAGithubRawBlobResponse withParameters:nil];	
}


#pragma mark NSURLConnection Delegate Methods

- (void)connection:(UAGithubURLConnection *)connection didFailWithError:(NSError *)error
{
	[self.connections removeObjectForKey:connection.identifier];
	
	if ([self isValidSelectorForDelegate:@selector(requestFailed:withError:)])
	{
		[delegate requestFailed:connection.identifier withError:error];
	}
			
	if ([self isValidSelectorForDelegate:@selector(connectionFinished:)])
	{
		[delegate connectionFinished:connection.identifier];
	}

}


- (void)connection:(UAGithubURLConnection *)connection didReceiveData:(NSData *)data
{
	[connection appendData:data];	
}


- (void)connection:(UAGithubURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	[connection resetDataLength];
    
    // Get response code.
    NSHTTPURLResponse *resp = (NSHTTPURLResponse *)response;
    int statusCode = resp.statusCode;
    
    if (statusCode >= 400) {
        NSError *error = [NSError errorWithDomain:@"HTTP" code:statusCode userInfo:nil];
		if ([self isValidSelectorForDelegate:@selector(requestFailed:withError:)])
		{
			[delegate requestFailed:connection.identifier withError:error];
		}
        
        [connection cancel];
		NSString *connectionIdentifier = connection.identifier;
		[connections removeObjectForKey:connectionIdentifier];
		if ([self isValidSelectorForDelegate:@selector(connectionFinished:)])
		{
			[delegate connectionFinished:connectionIdentifier];
		}
		
    } 
	
}


- (void)connectionDidFinishLoading:(UAGithubURLConnection *)connection
{
	[self parseDataForConnection:connection];
	[self.connections removeObjectForKey:connection.identifier];
	if ([self isValidSelectorForDelegate:@selector(connectionFinished:)])
	{
		[delegate connectionFinished:connection.identifier];
	}
	
}


@end
