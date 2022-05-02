#Projekt k diplomové práci Hardening Windows 10

Tento repozitář je součástí výstupů diplomové práce "Implementace zabezpečení operačního
systému Windows 10".
##Popis nástroje
Obsahuje skript, který skrze klíče registrů a auditní a bezpečnostní nastavení, pomáhá zabezpečit operační systém (tzv. hardening). Jednotlivá opatření pro hardening vzešla z analýzy doporučení od specializovaných a vládních organizací, které působí na poli kyberbezpečnosti. Jejich celý seznam je následující:
\begin{itemize}
    \item Microsoft - Windows 10 v21H2 Security Baseline,
    \item BSI - Projekt SiSyPHuS,
    \item NCSC - Průvodce zabezpečením zařízení - Windows,
    \item DoD - CyberExchange - Security Technical Implementation Guides - Windows,
    \item ACSC - Hardening pracovních stanic Windows 10 21H1,
    \item Canadian Centre for Cyber Security - Guidance for Hardening Microsoft Windows 10 Enterprise,
    \item MITRE ATT\&CK - Mitigations.
\end{itemize}

Cílovými uživateli tohoto nástroje jsou uživatelé OS Windows 10, kteří své zařízení nepoužívají v žádném doménovém režimu, který by centrálně řídil bezpečnostní nastavení skrze GPO. Může se tedy jednat o jednotlivce, ale i o zaměstnance menších společností, které nedisponují tolika zařízeními, aby pro ně dávala smysl doménová správa. Podle tohoto zaměření byla získaná opatření z výše uvedených doporučení analyzována a dle potřeby upravena.

Primárním podporovaným systémem je Windows 10 21H2 v edicích Home a Pro. Nástroj byl otestován i na jiných verzích Windows 10, na edici Education a i na Windows 11, bez identifikace jakýchkoliv problémů.

\section{Použití nástroje}

Před použitím je silně doporučeno udělat zálohu. Vzhledem k tomu, že se jedná o velké změny v registrech, není bohužel jiná možnost, než provést vytvoření backup image v rozšířeném startu Windows, ze které může být v případě problémů systém obnoven. Nejlepší variantou je otestování na neprodukčním systému.

Hlavním skriptem je hardening.ps1 v kořeni repozitáře. Pro plnou funkčnost je nutné jej spouštět s administrátorskými právy. Skript se pouští zadáním následujícího příkazu do okna PowerShellu (aktuální cesta musí být v adresáři se skriptem):
\begin{code}
.\hardening.ps1
\end{code}
Po spuštění je uživatel proveden krátkým dialogem v rámci CLI, kdy odpovídá na otázky ano (1) a ne (2). Tím je blíže specifikována sada opatření, která je posléze implementována úpravami klíčů v registrech. Dále skript upravuje i bezpečnostní a auditní nastavení a systémové služby. Pro ty jsou při běhu hlavního skriptu vytvářeny zálohy, které jsou uloženy do složky \textit{/backups}, ze které je možné je následně nahradit ve složce data kde jsou zdrojové soubory.

Další možností použití je pokročilý mód, při kterém je možné specifikovat, jaké csv soubory s nastaveními se mají nasadit. Jednotlivá opatření, seskupená dle mitigací z MITRE ATT\&CK, jsou ve složce \textit{/data}. Je tedy možné vybrat pouze některé soubory a i přidávat vlastní csv soubory, dodržující hlavičku: \textit{hive,path,value,type,data}. Syntaxe příkazu poté může vypadat třeba takto:
\begin{code}
.\hardening.ps1 exploit-protection.csv,account-policy.csv
\end{code}