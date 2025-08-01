using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;

namespace MatchAPI.Models2;

public partial class DBContextTest2 : DbContext
{
    public DBContextTest2()
    {
    }

    public DBContextTest2(DbContextOptions<DBContextTest2> options)
        : base(options)
    {
    }

    public virtual DbSet<Chapter> Chapters { get; set; }

    public virtual DbSet<GameSession> GameSessions { get; set; }

    public virtual DbSet<Leaderboard> Leaderboards { get; set; }

    public virtual DbSet<Level> Levels { get; set; }

    public virtual DbSet<Player> Players { get; set; }

    public virtual DbSet<PlayerProgress> PlayerProgresses { get; set; }

    public virtual DbSet<PlayerSetting> PlayerSettings { get; set; }

    public virtual DbSet<PlayerStat> PlayerStats { get; set; }

    public virtual DbSet<PlayerWeapon> PlayerWeapons { get; set; }

    public virtual DbSet<Season> Seasons { get; set; }

    public virtual DbSet<TowerProgress> TowerProgresses { get; set; }

    public virtual DbSet<Upgrade> Upgrades { get; set; }

    public virtual DbSet<VwCurrentSeasonLeaderboard> VwCurrentSeasonLeaderboards { get; set; }

    public virtual DbSet<VwPlayerProgressSummary> VwPlayerProgressSummaries { get; set; }

    public virtual DbSet<VwPlayerSummary> VwPlayerSummaries { get; set; }

    public virtual DbSet<Weapon> Weapons { get; set; }

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
#warning To protect potentially sensitive information in your connection string, you should move it out of source code. You can avoid scaffolding the connection string by using the Name= syntax to read it from configuration - see https://go.microsoft.com/fwlink/?linkid=2131148. For more guidance on storing connection strings, see https://go.microsoft.com/fwlink/?LinkId=723263.
        => optionsBuilder.UseSqlServer("Data Source=34.71.252.111;Initial Catalog=Match3Game;Persist Security Info=True;User ID=sqlserver;Password=123;Encrypt=False");

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Chapter>(entity =>
        {
            entity.HasKey(e => e.ChapterId).HasName("PK__Chapters__0893A34A3CA5A59B");

            entity.Property(e => e.ChapterId).ValueGeneratedNever();
            entity.Property(e => e.CreatedDate).HasDefaultValueSql("(getdate())");
            entity.Property(e => e.IsUnlocked).HasDefaultValue(false);
        });

        modelBuilder.Entity<GameSession>(entity =>
        {
            entity.HasKey(e => e.SessionId).HasName("PK__GameSess__C9F4927036400781");

            entity.Property(e => e.EnemyDefeated).HasDefaultValue(false);
            entity.Property(e => e.FinalScore).HasDefaultValue(0);
            entity.Property(e => e.IsCompleted).HasDefaultValue(false);
            entity.Property(e => e.StartTime).HasDefaultValueSql("(getdate())");

            entity.HasOne(d => d.Chapter).WithMany(p => p.GameSessions).HasConstraintName("FK__GameSessi__Chapt__10566F31");

            entity.HasOne(d => d.Player).WithMany(p => p.GameSessions).HasConstraintName("FK__GameSessi__Playe__0F624AF8");
        });

        modelBuilder.Entity<Leaderboard>(entity =>
        {
            entity.HasKey(e => e.LeaderboardId).HasName("PK__Leaderbo__B358A1E6D5C51DF3");

            entity.Property(e => e.CreatedDate).HasDefaultValueSql("(getdate())");
            entity.Property(e => e.Score).HasDefaultValue(0);
            entity.Property(e => e.UpdatedDate).HasDefaultValueSql("(getdate())");

            entity.HasOne(d => d.Player).WithMany(p => p.Leaderboards).HasConstraintName("FK__Leaderboa__Playe__06CD04F7");

            entity.HasOne(d => d.Season).WithMany(p => p.Leaderboards).HasConstraintName("FK__Leaderboa__Seaso__07C12930");
        });

        modelBuilder.Entity<Level>(entity =>
        {
            entity.HasKey(e => e.LevelId).HasName("PK__Levels__09F03C06909095F9");

            entity.Property(e => e.CreatedDate).HasDefaultValueSql("(getdate())");
            entity.Property(e => e.EnemyMaxHealth).HasDefaultValue(100);
            entity.Property(e => e.IsUnlocked).HasDefaultValue(false);
            entity.Property(e => e.RequiredLevel).HasDefaultValue(1);

            entity.HasOne(d => d.Chapter).WithMany(p => p.Levels).HasConstraintName("FK__Levels__ChapterI__5FB337D6");
        });

        modelBuilder.Entity<Player>(entity =>
        {
            entity.HasKey(e => e.PlayerId).HasName("PK__Players__4A4E74A840D8BAFC");

            entity.ToTable(tb =>
                {
                    tb.HasTrigger("tr_UpdateLastLogin");
                    tb.HasTrigger("tr_UpdateLeaderboard");
                });

            entity.Property(e => e.Coins).HasDefaultValue(9999);
            entity.Property(e => e.CreatedDate).HasDefaultValueSql("(getdate())");
            entity.Property(e => e.EquippedWeapon).HasDefaultValue("Sword");
            entity.Property(e => e.Gender).HasDefaultValue("Male");
            entity.Property(e => e.IsActive).HasDefaultValue(true);
            entity.Property(e => e.LanguagePreference).HasDefaultValue("English");
            entity.Property(e => e.LastLoginDate).HasDefaultValueSql("(getdate())");
            entity.Property(e => e.TowerRecord).HasDefaultValue(1);
        });

        modelBuilder.Entity<PlayerProgress>(entity =>
        {
            entity.HasKey(e => e.ProgressId).HasName("PK__PlayerPr__BAE29C85230E8F5E");

            entity.Property(e => e.AttemptsCount).HasDefaultValue(0);
            entity.Property(e => e.BestScore).HasDefaultValue(0);
            entity.Property(e => e.IsCompleted).HasDefaultValue(false);

            entity.HasOne(d => d.Chapter).WithMany(p => p.PlayerProgresses).HasConstraintName("FK__PlayerPro__Chapt__6754599E");

            entity.HasOne(d => d.Player).WithMany(p => p.PlayerProgresses).HasConstraintName("FK__PlayerPro__Playe__66603565");
        });

        modelBuilder.Entity<PlayerSetting>(entity =>
        {
            entity.HasKey(e => e.SettingId).HasName("PK__PlayerSe__54372AFD6F91EC14");

            entity.Property(e => e.Bgmenabled).HasDefaultValue(true);
            entity.Property(e => e.Bgmvolume).HasDefaultValue(7.0);
            entity.Property(e => e.FirstLaunch).HasDefaultValue(true);
            entity.Property(e => e.Language).HasDefaultValue("English");
            entity.Property(e => e.Sfxenabled).HasDefaultValue(true);
            entity.Property(e => e.Sfxvolume).HasDefaultValue(5.0);
            entity.Property(e => e.UpdatedDate).HasDefaultValueSql("(getdate())");

            entity.HasOne(d => d.Player).WithMany(p => p.PlayerSettings).HasConstraintName("FK__PlayerSet__Playe__1BC821DD");
        });

        modelBuilder.Entity<PlayerStat>(entity =>
        {
            entity.HasKey(e => e.StatId).HasName("PK__PlayerSt__3A162D1EE9DD57E8");

            entity.Property(e => e.HighestTowerFloor).HasDefaultValue(1);
            entity.Property(e => e.LastUpdated).HasDefaultValueSql("(getdate())");
            entity.Property(e => e.TotalDefeats).HasDefaultValue(0);
            entity.Property(e => e.TotalGamesPlayed).HasDefaultValue(0);
            entity.Property(e => e.TotalPlayTime).HasDefaultValue(0);
            entity.Property(e => e.TotalVictories).HasDefaultValue(0);

            entity.HasOne(d => d.Player).WithMany(p => p.PlayerStats).HasConstraintName("FK__PlayerSta__Playe__7F2BE32F");

            entity.HasOne(d => d.Season).WithMany(p => p.PlayerStats).HasConstraintName("FK__PlayerSta__Seaso__00200768");
        });

        modelBuilder.Entity<PlayerWeapon>(entity =>
        {
            entity.HasKey(e => e.PlayerWeaponId).HasName("PK__PlayerWe__DC5F94335052A879");

            entity.Property(e => e.IsOwned).HasDefaultValue(false);

            entity.HasOne(d => d.Player).WithMany(p => p.PlayerWeapons).HasConstraintName("FK__PlayerWea__Playe__534D60F1");

            entity.HasOne(d => d.WeaponNameNavigation).WithMany(p => p.PlayerWeapons)
                .HasPrincipalKey(p => p.WeaponName)
                .HasForeignKey(d => d.WeaponName)
                .HasConstraintName("FK__PlayerWea__Weapo__5441852A");
        });

        modelBuilder.Entity<Season>(entity =>
        {
            entity.HasKey(e => e.SeasonId).HasName("PK__Seasons__C1814E18B05615B0");

            entity.Property(e => e.CreatedDate).HasDefaultValueSql("(getdate())");
            entity.Property(e => e.IsActive).HasDefaultValue(false);
        });

        modelBuilder.Entity<TowerProgress>(entity =>
        {
            entity.HasKey(e => e.TowerProgressId).HasName("PK__TowerPro__7BF194EE029C5104");

            entity.Property(e => e.CurrentFloor).HasDefaultValue(1);
            entity.Property(e => e.CurrentPlayerHealth).HasDefaultValue(100);
            entity.Property(e => e.ExcessHealth).HasDefaultValue(0);
            entity.Property(e => e.HighestFloor).HasDefaultValue(1);
            entity.Property(e => e.LastPlayDate).HasDefaultValueSql("(getdate())");
            entity.Property(e => e.PowerPoints).HasDefaultValue(0);
            entity.Property(e => e.ShieldPoints).HasDefaultValue(0);

            entity.HasOne(d => d.Player).WithMany(p => p.TowerProgresses).HasConstraintName("FK__TowerProg__Playe__70DDC3D8");
        });

        modelBuilder.Entity<Upgrade>(entity =>
        {
            entity.HasKey(e => e.UpgradeId).HasName("PK__Upgrades__CA188BC51712AAC1");

            entity.Property(e => e.CreatedDate).HasDefaultValueSql("(getdate())");
            entity.Property(e => e.Level).HasDefaultValue(1);
            entity.Property(e => e.UpdatedDate).HasDefaultValueSql("(getdate())");

            entity.HasOne(d => d.Player).WithMany(p => p.Upgrades).HasConstraintName("FK__Upgrades__Player__48CFD27E");
        });

        modelBuilder.Entity<VwCurrentSeasonLeaderboard>(entity =>
        {
            entity.ToView("vw_CurrentSeasonLeaderboard");
        });

        modelBuilder.Entity<VwPlayerProgressSummary>(entity =>
        {
            entity.ToView("vw_PlayerProgressSummary");
        });

        modelBuilder.Entity<VwPlayerSummary>(entity =>
        {
            entity.ToView("vw_PlayerSummary");
        });

        modelBuilder.Entity<Weapon>(entity =>
        {
            entity.HasKey(e => e.WeaponId).HasName("PK__Weapons__541D0A1163D4C13D");

            entity.Property(e => e.CreatedDate).HasDefaultValueSql("(getdate())");
            entity.Property(e => e.IsDefaultWeapon).HasDefaultValue(false);
        });

        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}
