using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace MatchAPI.Models2;

[Table("TowerProgress")]
public partial class TowerProgress
{
    [Key]
    [Column("TowerProgressID")]
    public int TowerProgressId { get; set; }

    [Column("PlayerID")]
    [StringLength(50)]
    public string PlayerId { get; set; } = null!;

    public int? CurrentFloor { get; set; }

    public int? HighestFloor { get; set; }

    public int? CurrentPlayerHealth { get; set; }

    public int? ExcessHealth { get; set; }

    public int? ShieldPoints { get; set; }

    public int? PowerPoints { get; set; }

    public DateTime? LastPlayDate { get; set; }

    [ForeignKey("PlayerId")]
    [InverseProperty("TowerProgresses")]
    public virtual Player Player { get; set; } = null!;
}
