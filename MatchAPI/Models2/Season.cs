using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace MatchAPI.Models2;

[Index("SeasonNumber", Name = "UQ__Seasons__185D143042EAAA0E", IsUnique = true)]
public partial class Season
{
    [Key]
    [Column("SeasonID")]
    public int SeasonId { get; set; }

    public int SeasonNumber { get; set; }

    public DateTime StartDate { get; set; }

    public DateTime EndDate { get; set; }

    public bool? IsActive { get; set; }

    public DateTime? CreatedDate { get; set; }

    [InverseProperty("Season")]
    public virtual ICollection<Leaderboard> Leaderboards { get; set; } = new List<Leaderboard>();

    [InverseProperty("Season")]
    public virtual ICollection<PlayerStat> PlayerStats { get; set; } = new List<PlayerStat>();
}
