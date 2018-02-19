#import "RNConvertFile.h"
#import <AVFoundation/AVAsset.h>
#import <AVFoundation/AVAssetExportSession.h>
#import <AVFoundation/AVMediaFormat.h>
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>

@implementation RNConvertFile

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(convertFile:(NSString *)filePath
                  name:(NSString*)fileName
                  quality:(NSString*)fileQuality
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)

{
    NSString *setfileQuality = nil;
    if (fileQuality == nil || [fileQuality isEqualToString:@"medium"]) {
        setfileQuality = AVAssetExportPresetMediumQuality;
    } else if ([fileQuality isEqualToString:@"high"]) {
        setfileQuality = AVAssetExportPresetHighestQuality;
    } else if ([fileQuality isEqualToString:@"low"]) {
        setfileQuality = AVAssetExportPresetLowQuality;
    } else {
        setfileQuality = AVAssetExportPresetMediumQuality;
    }
//    NSLog(@"fsdf %@", fileQuality);
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSURL *ouputURL = [NSURL fileURLWithPath:[docDir stringByAppendingPathComponent:fileName]];
    NSString *newOuputURL = [ouputURL absoluteString];
    
    NSURL *inputURL = [NSURL fileURLWithPath:filePath];
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:inputURL options:nil];
    
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:setfileQuality];
    
    if(exportSession == nil)reject(@"exportSession is nil", nil, nil);
    
    exportSession.outputURL = ouputURL;
    exportSession.outputFileType = AVFileTypeMPEG4;
    exportSession.shouldOptimizeForNetworkUse = YES;
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        switch ([exportSession status])
        {
            case AVAssetExportSessionStatusFailed:
                reject(@"AVAssetExportSessionStatusFailed", nil, nil);
                break;
            case AVAssetExportSessionStatusCancelled:
                reject(@"AVAssetExportSessionStatusCancelled", nil, nil);
                break;
            case AVAssetExportSessionStatusCompleted:
                resolve(@{ @"path": newOuputURL });
                break;
            default:
                break;
        }
    }];
}

@end
