// Shim de gh : choisit le compte GitHub selon le depot, sans dependre du compte actif du trousseau.
// Depot Many0nne/* (remote origin du dossier courant, ou argument -R/--repo Many0nne/...) et GH_TOKEN absent :
// GH_TOKEN = jeton du compte Many0nne. Sinon gh tel quel (compte actif). Les arguments passent bruts (guillemets,
// retours a la ligne conserves). Compile vers %USERPROFILE%\bin\gh.exe par build.ps1, place avant gh dans le PATH.
using System;
using System.Diagnostics;
using System.Text.RegularExpressions;

static class GhShim
{
    const string RealGh = @"C:\Program Files\GitHub CLI\gh.exe";
    const string Owner = "Many0nne";

    // Cette methode permet de lancer le vrai gh avec les arguments bruts lorsqu'un appel passe par le shim,
    // apres avoir pose GH_TOKEN si le depot vise appartient a Many0nne.
    static int Main()
    {
        string raw = RawArguments();
        var psi = new ProcessStartInfo(RealGh, raw) { UseShellExecute = false };
        if (string.IsNullOrEmpty(Environment.GetEnvironmentVariable("GH_TOKEN")) && TargetsOwner(raw))
        {
            string token = Capture(RealGh, "auth token -u " + Owner);
            if (!string.IsNullOrEmpty(token))
                psi.EnvironmentVariables["GH_TOKEN"] = token;
        }
        using (var p = Process.Start(psi))
        {
            p.WaitForExit();
            return p.ExitCode;
        }
    }

    // Cette methode permet de recuperer la ligne de commande sans le nom du programme lorsqu'on relaie l'appel,
    // en respectant les guillemets du premier jeton.
    static string RawArguments()
    {
        string cl = Environment.CommandLine;
        int i = 0;
        if (cl.StartsWith("\""))
        {
            i = cl.IndexOf('"', 1);
            i = i < 0 ? cl.Length : i + 1;
        }
        else
        {
            while (i < cl.Length && cl[i] != ' ' && cl[i] != '\t') i++;
        }
        return cl.Substring(i).TrimStart(' ', '\t');
    }

    // Cette methode permet de savoir si l'appel vise un depot Many0nne lorsqu'on decide du compte :
    // argument de depot explicite, sinon remote origin du dossier courant.
    static bool TargetsOwner(string raw)
    {
        var ownerRe = new Regex(@"(^|[\s""'/:=])" + Owner + "/", RegexOptions.IgnoreCase);
        if (ownerRe.IsMatch(raw)) return true;
        string origin = Capture("git", "remote get-url origin");
        return Regex.IsMatch(origin ?? "", @"github\.com[:/]" + Owner + "/", RegexOptions.IgnoreCase);
    }

    // Cette methode permet de lire la sortie d'une commande courte lorsqu'on a besoin d'une valeur (jeton, URL) ;
    // chaine vide si elle echoue.
    static string Capture(string file, string args)
    {
        try
        {
            var psi = new ProcessStartInfo(file, args)
            {
                UseShellExecute = false,
                RedirectStandardOutput = true,
                RedirectStandardError = true,
                CreateNoWindow = true,
            };
            using (var p = Process.Start(psi))
            {
                string output = p.StandardOutput.ReadToEnd();
                p.StandardError.ReadToEnd();
                p.WaitForExit();
                return p.ExitCode == 0 ? output.Trim() : "";
            }
        }
        catch
        {
            return "";
        }
    }
}
