# Narrative Runner (Godot)

Bu repo, Godot 4 ile geliştirilmiş bir runner prototipidir.

## Godot .NET Durumu

Proje Godot .NET için hazırlanmıştır:

- C# proje dosyası: `Narrative-runner-master.csproj`
- C# scriptler:
  - `Scripts/Player.cs`
  - `Scripts/Runner.cs`
  - `Scripts/ProceduralCity.cs`
  - `Scripts/MainUI.cs`
- İlgili sahneler `.cs` scriptlere bağlanmıştır.

## Nasıl Çalıştırılır (Lokal)

1. Godot 4.2+ **.NET** sürümünü kurun.
2. .NET SDK kurulu olduğundan emin olun (`dotnet --info`).
3. Repo kökünde:

```bash
dotnet build Narrative-runner-master.csproj
```

4. Projeyi Godot .NET editor ile açın ve çalıştırın.

## Not

Bu CI/agent ortamında dış paket kaynaklarına erişim kısıtı olduğu için `dotnet` kurulumu başarısız olabilir. Bu nedenle derleme doğrulaması en güvenli şekilde lokal makinede yapılmalıdır.
