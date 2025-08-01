using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace MatchAPI.Models2;

[Index("PlayerId", "SeasonId", Name = "UQ__PlayerSt__D65660481573AC79", IsUnique = true)]
public partial class PlayerStat
{
    [Key]
    [Column("StatID")]
    public int StatId { get; set; }

    [Column("PlayerID")]
    [StringLength(50)]
    public string PlayerId { get; set; } = null!;

    [Column("SeasonID")]
    public int SeasonId { get; set; }

    public int? TotalGamesPlayed { get; set; }

    public int? TotalVictories { get; set; }

    public int? TotalDefeats { get; set; }

    public int? HighestTowerFloor { get; set; }

    public int? TotalPlayTime { get; set; }

    public DateTime? LastUpdated { get; set; }

    [ForeignKey("PlayerId")]
    [InverseProperty("PlayerStats")]
    public virtual Player Player { get; set; } = null!;

    [ForeignKey("SeasonId")]
    [InverseProperty("PlayerStats")]
    public virtual Season Season { get; set; } = null!;
}
