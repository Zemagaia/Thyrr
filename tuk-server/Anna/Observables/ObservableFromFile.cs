using System;
using System.IO;
using System.Linq;
using System.Reactive.Linq;

namespace Anna.Observables; 

public class ObservableFromFile : IObservable<byte[]> {
    private byte[] buffer;
    private int chunkSize;
    private FileStream fileStream;
    private IObservable<byte[]> subject; // = new Subject<byte[]>();

    public ObservableFromFile(string fileName, int chunkSize = 1024) {
        this.chunkSize = chunkSize;
        buffer = new byte[chunkSize];
        subject = Observable.Create<byte[]>(obs => {
            fileStream = new FileStream(fileName, FileMode.Open, FileAccess.Read, FileShare.Read);
            fileStream.BeginRead(buffer, 0, chunkSize,
                ar => EndReadCallback(ar, obs), null);
            return () => fileStream.Close();
        });
    }


    public IDisposable Subscribe(IObserver<byte[]> observer) {
        return subject.Subscribe(observer);
    }

    private void EndReadCallback(IAsyncResult ar, IObserver<byte[]> obs) {
        var result = fileStream.EndRead(ar);
        if (result == 0) {
            obs.OnCompleted();
            return;
        }

        obs.OnNext(buffer.Take(result).ToArray());
        if (result < chunkSize) {
            obs.OnCompleted();
            return;
        }

        buffer = new byte[chunkSize];
        fileStream.BeginRead(buffer, 0, chunkSize, a => EndReadCallback(a, obs), null);
    }
}