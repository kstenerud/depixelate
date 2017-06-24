//
//  main.m
//  depixelate
//
//  Created by Karl Stenerud on 1/2/14.
//  Copyright (c) 2014 Karl Stenerud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "xbrz.h"
#import "hqx.h"
#import "scalebit.h"

typedef bool (*ScaleFunction)(const void* srcData, void* dstData, int width, int height, int scale);

typedef struct
{
    const char* name;
    const int minScale;
    const int maxScale;
    ScaleFunction scaleFunction;
} Algorithm;


static bool scale_xbrz(const void* srcData, void* dstData, int width, int height, int scale)
{
    xbrz::scale(scale, (uint32_t*)srcData, (uint32_t*)dstData, width, height);
    return true;
}

static bool scale_hqx(const void* srcData, void* dstData, int width, int height, int scale)
{
    hqxInit();
    switch (scale)
    {
        case 2: {
            hq2x_32((uint32_t*)srcData, (uint32_t*)dstData, width, height);
            break;
        }
        case 3: {
            hq3x_32((uint32_t*)srcData, (uint32_t*)dstData, width, height);
            break;
        }
        case 4:
        default: {
            hq4x_32((uint32_t*)srcData, (uint32_t*)dstData, width, height);
            break;
        }
    }
    return true;
}

static bool scale_scale2x(const void* srcData, void* dstData, int width, int height, int scaleVal)
{
    scale2x_scale(scaleVal, dstData, 4*width*scaleVal, srcData, 4*width, 4, width, height);
    return true;
}


static const Algorithm algorithms[] =
{
    {
        "xbrz",
        2,
        5,
        scale_xbrz
    },
    {
        "hqx",
        2,
        4,
        scale_hqx
    },
    {
        "scale2x",
        2,
        4,
        scale_scale2x
    },
};
static const int algorithmsCount = sizeof(algorithms) / sizeof(*algorithms);


const Algorithm* getAlgorithm(const char* name)
{
    for(int i = 0; i < algorithmsCount; i++)
    {
        const Algorithm* algorithm = &algorithms[i];
        if(strcmp(name, algorithm->name) == 0)
        {
            return algorithm;
        }
    }
    return NULL;
}

int main(int argc, const char * argv[])
{
    @autoreleasepool
    {
        if(argc != 5)
        {
            printf("Usage: %s <algorithm> <scale> <srcfile> <dstfile>\n", argv[0]);
            printf("Algorithms:\n");
            for(int i = 0; i < algorithmsCount; i++)
            {
                const Algorithm* algorithm = &algorithms[i];
                printf("- %s\n", algorithm->name);
            }
            return 1;
        }

        const char* algoName = argv[1];
        int scale = atoi(argv[2]);
        NSString* srcFile = [NSString stringWithUTF8String:argv[3]];
        NSString* dstFile = [NSString stringWithUTF8String:argv[4]];

        const Algorithm* algorithm = getAlgorithm(algoName);
        if(algorithm == NULL)
        {
            printf("%s: Unknown algorithm\n", algoName);
            return 1;
        }
        if(scale < algorithm->minScale || scale > algorithm->maxScale)
        {
            printf("Scale must be from %d to %d\n", algorithm->minScale, algorithm->maxScale);
            return 1;
        }

        NSImage* image = [[NSImage alloc] initWithContentsOfFile:srcFile];
        if(image == nil)
        {
            printf("%s: Unable to open file\n", srcFile.UTF8String);
            return 1;
        }
        NSBitmapImageRep *rep = [[image representations] objectAtIndex:0];

        const void* srcData = (void*)rep.bitmapData;
        size_t dstByteCount = rep.pixelsWide * rep.pixelsHigh * rep.bitsPerPixel * scale;
        void* dstData = malloc(dstByteCount);
        if(!algorithm->scaleFunction(srcData, dstData, (int)rep.pixelsWide, (int)rep.pixelsHigh, scale))
        {
            printf("Scaling failed!\n");
            return 1;
        }

        NSBitmapImageRep* dstRep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:(unsigned char**)&dstData
                                                                           pixelsWide:rep.pixelsWide*scale
                                                                           pixelsHigh:rep.pixelsHigh*scale
                                                                        bitsPerSample:rep.bitsPerSample
                                                                      samplesPerPixel:rep.samplesPerPixel
                                                                             hasAlpha:rep.hasAlpha
                                                                             isPlanar:rep.isPlanar
                                                                       colorSpaceName:rep.colorSpaceName
                                                                         bitmapFormat:rep.bitmapFormat
                                                                          bytesPerRow:rep.bytesPerRow*scale
                                                                         bitsPerPixel:rep.bitsPerPixel];
        NSData* finalData = [dstRep representationUsingType:NSPNGFileType properties:Nil];;
        [finalData writeToFile:dstFile atomically:YES];
    }
    return 0;
}

