//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

#import "TSInfoMessage.h"
#import "ContactsManagerProtocol.h"
#import "SSKEnvironment.h"
#import <SignalCoreKit/NSDate+OWS.h>
#import <SignalServiceKit/SignalServiceKit-Swift.h>

NS_ASSUME_NONNULL_BEGIN

const InfoMessageUserInfoKey InfoMessageUserInfoKeyOldGroupModel = @"InfoMessageUserInfoKeyOldGroupModel";
const InfoMessageUserInfoKey InfoMessageUserInfoKeyNewGroupModel = @"InfoMessageUserInfoKeyNewGroupModel";
const InfoMessageUserInfoKey InfoMessageUserInfoKeyOldDisappearingMessageToken
    = @"InfoMessageUserInfoKeyOldDisappearingMessageToken";
const InfoMessageUserInfoKey InfoMessageUserInfoKeyNewDisappearingMessageToken
    = @"InfoMessageUserInfoKeyNewDisappearingMessageToken";
const InfoMessageUserInfoKey InfoMessageUserInfoKeyGroupUpdateSourceAddress
    = @"InfoMessageUserInfoKeyGroupUpdateSourceAddress";

NSUInteger TSInfoMessageSchemaVersion = 2;

@interface TSInfoMessage ()

@property (nonatomic, getter=wasRead) BOOL read;

@property (nonatomic, readonly) NSUInteger infoMessageSchemaVersion;

@end

#pragma mark -

@implementation TSInfoMessage

- (nullable instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (!self) {
        return self;
    }

    if (self.infoMessageSchemaVersion < 1) {
        _read = YES;
    }

    if (self.infoMessageSchemaVersion < 2) {
        NSString *_Nullable phoneNumber = [coder decodeObjectForKey:@"unregisteredRecipientId"];
        if (phoneNumber) {
            _unregisteredAddress = [[SignalServiceAddress alloc] initWithPhoneNumber:phoneNumber];
        }
    }

    _infoMessageSchemaVersion = TSInfoMessageSchemaVersion;

    if (self.isDynamicInteraction) {
        self.read = YES;
    }

    return self;
}

- (instancetype)initWithThread:(TSThread *)thread messageType:(TSInfoMessageType)infoMessage
{
    self = [super initMessageWithBuilder:[TSMessageBuilder messageBuilderWithThread:thread messageBody:nil]];
    if (!self) {
        return self;
    }

    _messageType = infoMessage;
    _infoMessageSchemaVersion = TSInfoMessageSchemaVersion;

    if (self.isDynamicInteraction) {
        self.read = YES;
    }

    return self;
}

- (instancetype)initWithThread:(TSThread *)thread
                   messageType:(TSInfoMessageType)infoMessage
                 customMessage:(NSString *)customMessage
{
    self = [self initWithThread:thread messageType:infoMessage];
    if (self) {
        _customMessage = customMessage;
    }
    return self;
}

- (instancetype)initWithThread:(TSThread *)thread
                   messageType:(TSInfoMessageType)infoMessageType
           infoMessageUserInfo:(NSDictionary<InfoMessageUserInfoKey, id> *)infoMessageUserInfo
{
    self = [self initWithThread:thread messageType:infoMessageType];
    if (!self) {
        return self;
    }

    _infoMessageUserInfo = infoMessageUserInfo;

    return self;
}

- (instancetype)initWithThread:(TSThread *)thread
                   messageType:(TSInfoMessageType)infoMessage
           unregisteredAddress:(SignalServiceAddress *)unregisteredAddress
{
    self = [self initWithThread:thread messageType:infoMessage];
    if (self) {
        _unregisteredAddress = unregisteredAddress;
    }
    return self;
}

// --- CODE GENERATION MARKER

// This snippet is generated by /Scripts/sds_codegen/sds_generate.py. Do not manually edit it, instead run `sds_codegen.sh`.

// clang-format off

- (instancetype)initWithGrdbId:(int64_t)grdbId
                      uniqueId:(NSString *)uniqueId
             receivedAtTimestamp:(uint64_t)receivedAtTimestamp
                          sortId:(uint64_t)sortId
                       timestamp:(uint64_t)timestamp
                  uniqueThreadId:(NSString *)uniqueThreadId
                   attachmentIds:(NSArray<NSString *> *)attachmentIds
                            body:(nullable NSString *)body
                    contactShare:(nullable OWSContact *)contactShare
                 expireStartedAt:(uint64_t)expireStartedAt
                       expiresAt:(uint64_t)expiresAt
                expiresInSeconds:(unsigned int)expiresInSeconds
              isViewOnceComplete:(BOOL)isViewOnceComplete
               isViewOnceMessage:(BOOL)isViewOnceMessage
                     linkPreview:(nullable OWSLinkPreview *)linkPreview
                  messageSticker:(nullable MessageSticker *)messageSticker
                   quotedMessage:(nullable TSQuotedMessage *)quotedMessage
    storedShouldStartExpireTimer:(BOOL)storedShouldStartExpireTimer
              wasRemotelyDeleted:(BOOL)wasRemotelyDeleted
                   customMessage:(nullable NSString *)customMessage
             infoMessageUserInfo:(nullable NSDictionary<InfoMessageUserInfoKey, id> *)infoMessageUserInfo
                     messageType:(TSInfoMessageType)messageType
                            read:(BOOL)read
             unregisteredAddress:(nullable SignalServiceAddress *)unregisteredAddress
{
    self = [super initWithGrdbId:grdbId
                        uniqueId:uniqueId
               receivedAtTimestamp:receivedAtTimestamp
                            sortId:sortId
                         timestamp:timestamp
                    uniqueThreadId:uniqueThreadId
                     attachmentIds:attachmentIds
                              body:body
                      contactShare:contactShare
                   expireStartedAt:expireStartedAt
                         expiresAt:expiresAt
                  expiresInSeconds:expiresInSeconds
                isViewOnceComplete:isViewOnceComplete
                 isViewOnceMessage:isViewOnceMessage
                       linkPreview:linkPreview
                    messageSticker:messageSticker
                     quotedMessage:quotedMessage
      storedShouldStartExpireTimer:storedShouldStartExpireTimer
                wasRemotelyDeleted:wasRemotelyDeleted];

    if (!self) {
        return self;
    }

    _customMessage = customMessage;
    _infoMessageUserInfo = infoMessageUserInfo;
    _messageType = messageType;
    _read = read;
    _unregisteredAddress = unregisteredAddress;

    return self;
}

// clang-format on

// --- CODE GENERATION MARKER

#pragma mark - Dependencies

- (id<ContactsManagerProtocol>)contactsManager
{
    return SSKEnvironment.shared.contactsManager;
}

#pragma mark -

+ (instancetype)userNotRegisteredMessageInThread:(TSThread *)thread address:(SignalServiceAddress *)address
{
    OWSAssertDebug(thread);
    OWSAssertDebug(address.isValid);

    return [[self alloc] initWithThread:thread messageType:TSInfoMessageUserNotRegistered unregisteredAddress:address];
}

- (OWSInteractionType)interactionType
{
    return OWSInteractionType_Info;
}

- (NSString *)systemMessageTextWithTransaction:(SDSAnyReadTransaction *)transaction
{
    switch (self.messageType) {
        case TSInfoMessageSyncedThread:
            return NSLocalizedString(@"INFO_MESSAGE_SYNCED_THREAD",
                                     @"Shown in inbox and conversation after syncing as a placeholder indicating why your message history "
                                     @"is missing.");
        default:
            return [self previewTextWithTransaction:transaction];
    }
}

- (NSString *)previewTextWithTransaction:(SDSAnyReadTransaction *)transaction
{
    switch (_messageType) {
        case TSInfoMessageTypeSessionDidEnd:
            return NSLocalizedString(@"SECURE_SESSION_RESET", nil);
        case TSInfoMessageTypeUnsupportedMessage:
            return NSLocalizedString(@"UNSUPPORTED_ATTACHMENT", nil);
        case TSInfoMessageUserNotRegistered:
            if (self.unregisteredAddress.isValid) {
                NSString *recipientName = [self.contactsManager displayNameForAddress:self.unregisteredAddress
                                                                          transaction:transaction];
                return [NSString stringWithFormat:NSLocalizedString(@"ERROR_UNREGISTERED_USER_FORMAT",
                                                      @"Format string for 'unregistered user' error. Embeds {{the "
                                                      @"unregistered user's name or signal id}}."),
                                 recipientName];
            } else {
                return NSLocalizedString(@"CONTACT_DETAIL_COMM_TYPE_INSECURE", nil);
            }
        case TSInfoMessageTypeGroupQuit:
            return NSLocalizedString(@"GROUP_YOU_LEFT", nil);
        case TSInfoMessageTypeGroupUpdate:
            return [self groupUpdateDescriptionWithTransaction:transaction];
        case TSInfoMessageAddToContactsOffer:
            return NSLocalizedString(@"ADD_TO_CONTACTS_OFFER",
                @"Message shown in conversation view that offers to add an unknown user to your phone's contacts.");
        case TSInfoMessageVerificationStateChange:
            return NSLocalizedString(@"VERIFICATION_STATE_CHANGE_GENERIC",
                @"Generic message indicating that verification state changed for a given user.");
        case TSInfoMessageAddUserToProfileWhitelistOffer:
            return NSLocalizedString(@"ADD_USER_TO_PROFILE_WHITELIST_OFFER",
                @"Message shown in conversation view that offers to share your profile with a user.");
        case TSInfoMessageAddGroupToProfileWhitelistOffer:
            return NSLocalizedString(@"ADD_GROUP_TO_PROFILE_WHITELIST_OFFER",
                @"Message shown in conversation view that offers to share your profile with a group.");
        case TSInfoMessageTypeDisappearingMessagesUpdate:
            break;
        case TSInfoMessageUnknownProtocolVersion:
            break;
        case TSInfoMessageUserJoinedSignal: {
            SignalServiceAddress *address = [TSContactThread contactAddressFromThreadId:self.uniqueThreadId
                                                                            transaction:transaction];
            NSString *recipientName = [self.contactsManager displayNameForAddress:address transaction:transaction];
            NSString *format = NSLocalizedString(@"INFO_MESSAGE_USER_JOINED_SIGNAL_BODY_FORMAT",
                @"Shown in inbox and conversation when a user joins Signal, embeds the new user's {{contact "
                @"name}}");
            return [NSString stringWithFormat:format, recipientName];
        }
        case TSInfoMessageSyncedThread:
            return @"";
    }

    OWSFailDebug(@"Unknown info message type");
    return @"";
}

#pragma mark - OWSReadTracking

- (BOOL)shouldAffectUnreadCounts
{
    switch (self.messageType) {
        case TSInfoMessageTypeSessionDidEnd:
        case TSInfoMessageUserNotRegistered:
        case TSInfoMessageTypeUnsupportedMessage:
        case TSInfoMessageTypeGroupUpdate:
        case TSInfoMessageTypeGroupQuit:
        case TSInfoMessageTypeDisappearingMessagesUpdate:
        case TSInfoMessageAddToContactsOffer:
        case TSInfoMessageVerificationStateChange:
        case TSInfoMessageAddUserToProfileWhitelistOffer:
        case TSInfoMessageAddGroupToProfileWhitelistOffer:
        case TSInfoMessageUnknownProtocolVersion:
        case TSInfoMessageSyncedThread:
            return NO;
        case TSInfoMessageUserJoinedSignal:
            // In the conversation list, we want conversations with an unread "new user" notification to
            // be badged and bolded, like they received a message.
            return YES;
    }
}

- (uint64_t)expireStartedAt
{
    return 0;
}

- (void)markAsReadAtTimestamp:(uint64_t)readTimestamp
                       thread:(TSThread *)thread
                 circumstance:(OWSReadCircumstance)circumstance
                  transaction:(SDSAnyWriteTransaction *)transaction
{
    OWSAssertDebug(transaction);

    if (self.read) {
        return;
    }

    OWSLogDebug(@"marking as read uniqueId: %@ which has timestamp: %llu", self.uniqueId, self.timestamp);

    [self anyUpdateInfoMessageWithTransaction:transaction
                                        block:^(TSInfoMessage *message) {
                                            message.read = YES;
                                        }];

    // Ignore `circumstance` - we never send read receipts for info messages.
}

@end

NS_ASSUME_NONNULL_END
