using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace MatchAPI.Models2;

[Index("PlayerId", "UpgradeType", Name = "UQ__Upgrades__6E8DEF10A76CEFFF", IsUnique = true)]
public partial class Upgrade
{
    [Key]
    [Column("UpgradeID")]
    public int UpgradeId { get; set; }

    [Column("PlayerID")]
    [StringLength(50)]
    public string PlayerId { get; set; } = null!;

    [StringLength(20)]
    public string UpgradeType { get; set; } = null!;

    public int? Level { get; set; }

    public DateTime? CreatedDate { get; set; }

    public DateTime? UpdatedDate { get; set; }

    [ForeignKey("PlayerId")]
    [InverseProperty("Upgrades")]
    public virtual Player Player { get; set; } = null!;
}
