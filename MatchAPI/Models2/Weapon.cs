using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace MatchAPI.Models2;

[Index("WeaponName", Name = "UQ__Weapons__4EFD147D43DA932A", IsUnique = true)]
public partial class Weapon
{
    [Key]
    [Column("WeaponID")]
    public int WeaponId { get; set; }

    [StringLength(50)]
    public string WeaponName { get; set; } = null!;

    public int Price { get; set; }

    [StringLength(255)]
    public string? Description { get; set; }

    [StringLength(255)]
    public string? AssetPath { get; set; }

    public bool? IsDefaultWeapon { get; set; }

    public DateTime? CreatedDate { get; set; }

    [InverseProperty("WeaponNameNavigation")]
    public virtual ICollection<PlayerWeapon> PlayerWeapons { get; set; } = new List<PlayerWeapon>();
}
