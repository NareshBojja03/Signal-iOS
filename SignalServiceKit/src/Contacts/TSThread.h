//
// Copyright 2017 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

#import <SignalServiceKit/BaseModel.h>

NS_ASSUME_NONNULL_BEGIN

@class GRDBReadTransaction;
@class MessageBody;
@class MessageBodyRanges;
@class OWSDisappearingMessagesConfiguration;
@class SDSAnyReadTransaction;
@class SDSAnyWriteTransaction;
@class SignalServiceAddress;
@class TSInteraction;
@class TSInvalidIdentityKeyReceivingErrorMessage;
@class ThreadReplyInfoObjC;

typedef NS_CLOSED_ENUM(NSUInteger, TSThreadMentionNotificationMode) {
    TSThreadMentionNotificationMode_Default = 0,
    TSThreadMentionNotificationMode_Always,
    TSThreadMentionNotificationMode_Never
};

typedef NS_CLOSED_ENUM(NSUInteger, TSThreadStoryViewMode) {
    TSThreadStoryViewMode_Default = 0,
    TSThreadStoryViewMode_Explicit,
    TSThreadStoryViewMode_BlockList,
    TSThreadStoryViewMode_Disabled
};

/**
 *  TSThread is the superclass of TSContactThread, TSGroupThread, and TSPrivateStoryThread
 */
@interface TSThread : BaseModel

@property (nonatomic, readonly) TSThreadStoryViewMode storyViewMode;
@property (nonatomic, readonly, nullable) NSNumber *lastSentStoryTimestamp;

@property (nonatomic) BOOL shouldThreadBeVisible;
@property (nonatomic, readonly, nullable) NSDate *creationDate;
@property (nonatomic, readonly) BOOL isArchivedByLegacyTimestampForSorting DEPRECATED_MSG_ATTRIBUTE("this property is only to be used in the sortId migration");
@property (nonatomic, readonly) BOOL isArchivedObsolete;
@property (nonatomic, readonly) BOOL isMarkedUnreadObsolete;

// This maintains the row Id that was at the bottom of the conversation
// the last time the user viewed this thread so we can restore their
// scroll position.
//
// If the referenced message is deleted, this value is
// updated to point to the previous message in the conversation.
//
// If a new message is inserted into the conversation, this value
// is cleared. We only restore this state if there are no unread messages.
@property (nonatomic, readonly) uint64_t lastVisibleSortIdObsolete;
@property (nonatomic, readonly) double lastVisibleSortIdOnScreenPercentageObsolete;

// zero if thread has never had an interaction.
// The corresponding interaction may have been deleted.
@property (nonatomic, readonly) uint64_t lastInteractionRowId;

- (instancetype)init NS_DESIGNATED_INITIALIZER;
- (nullable instancetype)initWithCoder:(NSCoder *)coder NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithUniqueId:(NSString *)uniqueId NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithGrdbId:(int64_t)grdbId uniqueId:(NSString *)uniqueId NS_UNAVAILABLE;

// --- CODE GENERATION MARKER

// This snippet is generated by /Scripts/sds_codegen/sds_generate.py. Do not manually edit it, instead run `sds_codegen.sh`.

// clang-format off

- (instancetype)initWithGrdbId:(int64_t)grdbId
                      uniqueId:(NSString *)uniqueId
   conversationColorNameObsolete:(NSString *)conversationColorNameObsolete
                    creationDate:(nullable NSDate *)creationDate
              isArchivedObsolete:(BOOL)isArchivedObsolete
          isMarkedUnreadObsolete:(BOOL)isMarkedUnreadObsolete
            lastInteractionRowId:(uint64_t)lastInteractionRowId
          lastSentStoryTimestamp:(nullable NSNumber *)lastSentStoryTimestamp
       lastVisibleSortIdObsolete:(uint64_t)lastVisibleSortIdObsolete
lastVisibleSortIdOnScreenPercentageObsolete:(double)lastVisibleSortIdOnScreenPercentageObsolete
         mentionNotificationMode:(TSThreadMentionNotificationMode)mentionNotificationMode
                    messageDraft:(nullable NSString *)messageDraft
          messageDraftBodyRanges:(nullable MessageBodyRanges *)messageDraftBodyRanges
          mutedUntilDateObsolete:(nullable NSDate *)mutedUntilDateObsolete
     mutedUntilTimestampObsolete:(uint64_t)mutedUntilTimestampObsolete
           shouldThreadBeVisible:(BOOL)shouldThreadBeVisible
                   storyViewMode:(TSThreadStoryViewMode)storyViewMode
NS_DESIGNATED_INITIALIZER NS_SWIFT_NAME(init(grdbId:uniqueId:conversationColorNameObsolete:creationDate:isArchivedObsolete:isMarkedUnreadObsolete:lastInteractionRowId:lastSentStoryTimestamp:lastVisibleSortIdObsolete:lastVisibleSortIdOnScreenPercentageObsolete:mentionNotificationMode:messageDraft:messageDraftBodyRanges:mutedUntilDateObsolete:mutedUntilTimestampObsolete:shouldThreadBeVisible:storyViewMode:));

// clang-format on

// --- CODE GENERATION MARKER

@property (nonatomic, readonly) NSString *conversationColorNameObsolete;

/**
 * @returns recipientId for each recipient in the thread
 */

@property (nonatomic, readonly) NSArray<SignalServiceAddress *> *recipientAddressesWithSneakyTransaction;
- (NSArray<SignalServiceAddress *> *)recipientAddressesWithTransaction:(SDSAnyReadTransaction *)transaction;

@property (nonatomic, readonly) BOOL isNoteToSelf;

#pragma mark Interactions

/**
 * Get all messages in the thread we weren't able to decrypt
 */
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
- (NSArray<TSInvalidIdentityKeyReceivingErrorMessage *> *)receivedMessagesForInvalidKey:(NSData *)key;
#pragma clang diagnostic pop

- (BOOL)hasSafetyNumbers;

- (nullable TSInteraction *)lastInteractionForInboxWithTransaction:(SDSAnyReadTransaction *)transaction
    NS_SWIFT_NAME(lastInteractionForInbox(transaction:));

- (nullable TSInteraction *)firstInteractionAtOrAroundSortId:(uint64_t)sortId
                                                 transaction:(SDSAnyReadTransaction *)transaction
    NS_SWIFT_NAME(firstInteraction(atOrAroundSortId:transaction:));

/**
 *  Updates the thread's caches of the latest interaction.
 *
 *  @param message Latest Interaction to take into consideration.
 *  @param transaction Database transaction.
 */
- (void)updateWithInsertedMessage:(TSInteraction *)message transaction:(SDSAnyWriteTransaction *)transaction;
- (void)updateWithUpdatedMessage:(TSInteraction *)message transaction:(SDSAnyWriteTransaction *)transaction;
- (void)updateWithRemovedMessage:(TSInteraction *)message transaction:(SDSAnyWriteTransaction *)transaction;
- (BOOL)hasPendingMessageRequestWithTransaction:(GRDBReadTransaction *)transaction
    NS_SWIFT_NAME(hasPendingMessageRequest(transaction:));

#pragma mark Archival

- (void)softDeleteThreadWithTransaction:(SDSAnyWriteTransaction *)transaction;

- (void)removeAllThreadInteractionsWithTransaction:(SDSAnyWriteTransaction *)transaction
    NS_SWIFT_NAME(removeAllThreadInteractions(transaction:));

/**
 *  Sets the draft of a thread. Typically called when leaving a conversation view.
 *
 *  @param draftMessageBody Draft to be saved.
 *  @param transaction Database transaction.
 */
- (void)updateWithDraft:(nullable MessageBody *)draftMessageBody
              replyInfo:(nullable ThreadReplyInfoObjC *)replyInfo
            transaction:(SDSAnyWriteTransaction *)transaction;

@property (atomic, readonly) uint64_t mutedUntilTimestampObsolete;
@property (nonatomic, readonly, nullable) NSDate *mutedUntilDateObsolete;

@property (nonatomic, readonly) TSThreadMentionNotificationMode mentionNotificationMode;

#pragma mark - Update With... Methods

- (void)updateWithMentionNotificationMode:(TSThreadMentionNotificationMode)mentionNotificationMode
                              transaction:(SDSAnyWriteTransaction *)transaction
    NS_SWIFT_NAME(updateWithMentionNotificationMode(_:transaction:));

- (void)updateWithShouldThreadBeVisible:(BOOL)shouldThreadBeVisible
                            transaction:(SDSAnyWriteTransaction *)transaction
    NS_SWIFT_NAME(updateWithShouldThreadBeVisible(_:transaction:));

- (void)updateWithLastSentStoryTimestamp:(nullable NSNumber *)lastSentStoryTimestamp
                             transaction:(SDSAnyWriteTransaction *)transaction
    NS_SWIFT_NAME(updateWithLastSentStoryTimestamp(_:transaction:));

- (void)updateWithStoryViewMode:(TSThreadStoryViewMode)storyViewMode
                    transaction:(SDSAnyWriteTransaction *)transaction
    NS_SWIFT_NAME(updateWithStoryViewMode(_:transaction:));

@end

NS_ASSUME_NONNULL_END
