using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace MatchAPI.Models2;

[Table("Leaderboard")]
[Index("PlayerId", "SeasonId", Name = "UQ__Leaderbo__D6566048A64882AC", IsUnique = true)]
public partial class Leaderboard
{
    [Key]
    [Column("LeaderboardID")]
    public int LeaderboardId { get; set; }

    [Column("PlayerID")]
    [StringLength(50)]
    public string PlayerId { get; set; } = null!;

    [Column("SeasonID")]
    public int SeasonId { get; set; }

    public int TowerLevel { get; set; }

    public int? Score { get; set; }

    public int? Rank { get; set; }

    public DateTime? CreatedDate { get; set; }

    public DateTime? UpdatedDate { get; set; }

    [ForeignKey("PlayerId")]
    [InverseProperty("Leaderboards")]
    public virtual Player Player { get; set; } = null!;

    [ForeignKey("SeasonId")]
    [InverseProperty("Leaderboards")]
    public virtual Season Season { get; set; } = null!;
}
