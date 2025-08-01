using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace MatchAPI.Models2;

public partial class Player
{
    [Key]
    [Column("PlayerID")]
    [StringLength(50)]
    public string PlayerId { get; set; } = null!;

    [StringLength(100)]
    public string PlayerName { get; set; } = null!;

    [StringLength(255)]
    public string Password { get; set; } = null!;

    [StringLength(100)]
    public string? Email { get; set; }

    [StringLength(20)]
    public string? Gender { get; set; }

    [StringLength(20)]
    public string? LanguagePreference { get; set; }

    public int? TowerRecord { get; set; }

    public int? Coins { get; set; }

    [StringLength(50)]
    public string? EquippedWeapon { get; set; }

    public DateTime? CreatedDate { get; set; }

    public DateTime? LastLoginDate { get; set; }

    public bool? IsActive { get; set; }

    [InverseProperty("Player")]
    public virtual ICollection<GameSession> GameSessions { get; set; } = new List<GameSession>();

    [InverseProperty("Player")]
    public virtual ICollection<Leaderboard> Leaderboards { get; set; } = new List<Leaderboard>();

    [InverseProperty("Player")]
    public virtual ICollection<PlayerProgress> PlayerProgresses { get; set; } = new List<PlayerProgress>();

    [InverseProperty("Player")]
    public virtual ICollection<PlayerSetting> PlayerSettings { get; set; } = new List<PlayerSetting>();

    [InverseProperty("Player")]
    public virtual ICollection<PlayerStat> PlayerStats { get; set; } = new List<PlayerStat>();

    [InverseProperty("Player")]
    public virtual ICollection<PlayerWeapon> PlayerWeapons { get; set; } = new List<PlayerWeapon>();

    [InverseProperty("Player")]
    public virtual ICollection<TowerProgress> TowerProgresses { get; set; } = new List<TowerProgress>();

    [InverseProperty("Player")]
    public virtual ICollection<Upgrade> Upgrades { get; set; } = new List<Upgrade>();
}
