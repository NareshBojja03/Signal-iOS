//
// Copyright 2024 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import AVFoundation
import Foundation

public class AttachmentContentValidatorImpl: AttachmentContentValidator {

    public init() {}

    public func validateContents(
        data: Data,
        mimeType: String
    ) throws -> Attachment.ContentType {
        return try validateContents(input: .inMemory(data), mimeType: mimeType)
    }

    public func validateContents(
        fileUrl: URL,
        mimeType: String
    ) throws -> Attachment.ContentType {
        return try validateContents(input: .unencryptedFile(fileUrl), mimeType: mimeType)
    }

    public func validateContents(
        encryptedFileAt fileUrl: URL,
        encryptionKey: Data,
        plaintextLength: UInt32,
        mimeType: String
    ) throws -> Attachment.ContentType {
        return try validateContents(
            input: .encryptedFile(
                fileUrl,
                encryptionKey: encryptionKey,
                plaintextLength: plaintextLength
            ),
            mimeType: mimeType
        )
    }

    // MARK: - Private

    // MARK: Genericizing inputs

    private enum Input {
        case inMemory(Data)
        case unencryptedFile(URL)
        case encryptedFile(URL, encryptionKey: Data, plaintextLength: UInt32)
    }

    private func rawContentType(mimeType: String) -> Attachment.ContentTypeRaw {
        if MimeTypeUtil.isSupportedVideoMimeType(mimeType) {
            return .video
        } else if MimeTypeUtil.isSupportedAudioMimeType(mimeType) {
            return .audio
        } else if MimeTypeUtil.isSupportedDefinitelyAnimatedMimeType(mimeType) {
            return .animatedImage
        } else if MimeTypeUtil.isSupportedImageMimeType(mimeType) {
            return .image
        } else if MimeTypeUtil.isSupportedMaybeAnimatedMimeType(mimeType) {
            return .animatedImage
        } else {
            return .file
        }
    }

    private func validateContents(
        input: Input,
        mimeType: String
    ) throws -> Attachment.ContentType {
        switch rawContentType(mimeType: mimeType) {
        case .invalid:
            return .invalid
        case .file:
            return .file
        case .image, .animatedImage:
            return try validateImageType(input, mimeType: mimeType)
        case .video:
            return try validateVideoType(input, mimeType: mimeType)
        case .audio:
            return try validateAudioType(input, mimeType: mimeType)
        }
    }

    // MARK: Image/Animated

    // Includes static and animated image validation.
    private func validateImageType(_ input: Input, mimeType: String) throws -> Attachment.ContentType {
        let imageSource: OWSImageSource = try {
            switch input {
            case .inMemory(let data):
                return data
            case .unencryptedFile(let fileUrl):
                return try FileHandleImageSource(fileUrl: fileUrl)
            case let .encryptedFile(fileUrl, encryptionKey, plaintextLength):
                return try EncryptedFileHandleImageSource(
                    encryptedFileUrl: fileUrl,
                    encryptionKey: encryptionKey,
                    plaintextLength: plaintextLength
                )
            }
        }()

        let imageMetadataResult = imageSource.imageMetadata(
            mimeTypeForValidation: mimeType
        )

        let imageMetadata: ImageMetadata
        switch imageMetadataResult {
        case .genericSizeLimitExceeded:
            throw OWSAssertionError("Attachment size should have been validated before reching this point!")
        case .imageTypeSizeLimitExceeded:
            throw OWSAssertionError("Image size too large")
        case .invalid:
            return .invalid
        case .valid(let metadata):
            imageMetadata = metadata
        case .mimeTypeMismatch(let metadata), .fileExtensionMismatch(let metadata):
            // Ignore these types of errors for now; we did so historically
            // and introducing a new failure mode should be done carefully
            // as it may cause us to blow up for attachments we previously "handled"
            // even if the contents didn't match the mime type.
            owsFailDebug("MIME type mismatch")
            imageMetadata = metadata
        }

        guard imageMetadata.isValid else {
            return .invalid
        }

        let pixelSize = imageMetadata.pixelSize
        if imageMetadata.isAnimated {
            return .animatedImage(pixelSize: pixelSize)
        } else {
            return .image(pixelSize: pixelSize)
        }
    }

    // MARK: Video

    private func validateVideoType(_ input: Input, mimeType: String) throws -> Attachment.ContentType {
        fatalError("Unimplemented")
    }

    // MARK: Audio

    private func validateAudioType(_ input: Input, mimeType: String) throws -> Attachment.ContentType {
        fatalError("Unimplemented")
    }
}