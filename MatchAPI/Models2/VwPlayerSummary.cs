using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace MatchAPI.Models2;

[Keyless]
public partial class VwPlayerSummary
{
    [Column("PlayerID")]
    [StringLength(50)]
    public string PlayerId { get; set; } = null!;

    [StringLength(100)]
    public string PlayerName { get; set; } = null!;

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

    public int? CurrentFloor { get; set; }

    public int? HighestFloor { get; set; }

    public int? CurrentPlayerHealth { get; set; }

    public int? ExcessHealth { get; set; }

    public int? ShieldPoints { get; set; }

    public int? PowerPoints { get; set; }

    public DateTime? LastPlayDate { get; set; }

    public int? OwnedWeapons { get; set; }

    public int? SwordLevel { get; set; }

    public int? HeartLevel { get; set; }

    public int? StarLevel { get; set; }

    public int? ShieldLevel { get; set; }

    public int? CompletedLevels { get; set; }

    public int? TotalLevelsAttempted { get; set; }
}
