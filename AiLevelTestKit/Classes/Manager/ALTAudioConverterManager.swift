//
//  ALTAudioConverterManager.swift
//  AiLevelTestKit
//
//  Created by Jun-kyu Jeon on 2021/03/22.
//

import Foundation
import lame

import AVFoundation

class ALTAudioConverterManager {

    private static let encoderQueue = DispatchQueue(label: "com.audio.encoder.queue")

    class func encodeToMp3(
        inPcmPath: String,
        outMp3Path: String,
        onProgress: @escaping (Float) -> (Void),
        onComplete: @escaping () -> (Void)
    ) {
        encoderQueue.async {
            guard let fileUrl = URL(string: inPcmPath),
                  let audioFile = try? AVAudioFile(forReading: fileUrl) else {
                onComplete()
                return
            }

            let lame = lame_init()
            lame_set_in_samplerate(lame, 44100)
            lame_set_out_samplerate(lame, 0)
//            lame_set_brate(lame, 0)
//            lame_set_quality(lame, 4)
            lame_set_VBR(lame, vbr_off)
            lame_init_params(lame)

            let pcmFile: UnsafeMutablePointer<FILE> = fopen(inPcmPath, "rb")
//            fseek(pcmFile, 0 , SEEK_END)
            let fileSize = ftell(pcmFile)
            // Skip file header.
            let fileHeader = 4 * 1024
            fseek(pcmFile, fileHeader, SEEK_CUR)

            let mp3File: UnsafeMutablePointer<FILE> = fopen(outMp3Path, "wb")

            let pcmSize = 1024 * 8
            let pcmbuffer = UnsafeMutablePointer<Int16>.allocate(capacity: Int(pcmSize * 2))

            let mp3Size: Int32 = 1024 * 8
            let mp3buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(mp3Size))

            var write: Int32 = 0
            var read = 0

            repeat {

                let size = MemoryLayout<Int16>.size * 2
                read = fread(pcmbuffer, size, pcmSize, pcmFile)
                // Progress
                if read != 0 {
                    let progress = Float(ftell(pcmFile)) / Float(fileSize)
                    DispatchQueue.main.sync { onProgress(progress) }
                }

                if read == 0 {
                    write = lame_encode_flush(lame, mp3buffer, mp3Size)
                } else {
                    write = lame_encode_buffer_interleaved(lame, pcmbuffer, Int32(read), mp3buffer, mp3Size)
                }

                fwrite(mp3buffer, Int(write), 1, mp3File)

            } while read != 0

            // Clean up
            lame_close(lame)
            fclose(mp3File)
            fclose(pcmFile)

            pcmbuffer.deallocate()
            mp3buffer.deallocate()

            DispatchQueue.main.sync { onComplete() }
            
//            do {
//                var read: Int, write: Int
//
//                let pcm = fopen(pcm, <#T##__mode: UnsafePointer<Int8>!##UnsafePointer<Int8>!#>)
//            } catch {
//
//            }
//            @try {
//                int read, write;
//
//                FILE *pcm = fopen([filePath cStringUsingEncoding:1], "rb");  //source
//                fseek(pcm, 4*1024, SEEK_CUR);                                   //skip file header
//                FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:1], "wb");  //output
//
//                const int PCM_SIZE = 8192;
//                const int MP3_SIZE = 8192;
//                short int pcm_buffer[PCM_SIZE*2];
//                unsigned char mp3_buffer[MP3_SIZE];
//
//                lame_t lame = lame_init();
//                lame_set_in_samplerate(lame, 44100);
//                lame_set_VBR(lame, vbr_default);
//                lame_init_params(lame);
//
//                do {
//                    read = fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
//                    if (read == 0)
//                        write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
//                    else
//                        write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
//
//                    fwrite(mp3_buffer, write, 1, mp3);
//
//                } while (read != 0);
//
//                lame_close(lame);
//                fclose(mp3);
//                fclose(pcm);
//            }
//            @catch (NSException *exception) {
//                NSLog(@"%@",[exception description]);
//            }
//            @finally {
//                [self performSelectorOnMainThread:@selector(convertMp3Finish)
//                                       withObject:nil
//                                    waitUntilDone:YES];
//            }
        }
    }
}

extension String {

  func toPointer() -> UnsafePointer<UInt8>? {
    guard let data = self.data(using: String.Encoding.utf8) else { return nil }

    let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: data.count)
    let stream = OutputStream(toBuffer: buffer, capacity: data.count)

    stream.open()
    data.withUnsafeBytes({ (p: UnsafePointer<UInt8>) -> Void in
      stream.write(p, maxLength: data.count)
    })

    stream.close()

    return UnsafePointer<UInt8>(buffer)
  }
}
